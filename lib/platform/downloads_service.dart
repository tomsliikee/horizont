import 'dart:async';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../browser/tabs/tabs_notifier.dart';
import '../browser/web_engine.dart';
import '../data/library.dart';
import '../data/library_providers.dart';
import 'horizont_webkit.dart';

/// How far a running download is, for the downloads screen.
@immutable
class LiveProgress {
  const LiveProgress({
    required this.fraction,
    this.remaining,
    this.expectedBytes,
  });

  /// 0 to 1; negative while the size is unknown.
  final double fraction;
  final Duration? remaining;
  final int? expectedBytes;
}

/// Downloads into the shared Download folder (PLAN 4.3). Overridden in
/// `main` with [BackgroundDownloadsService]; tests use [RecordingDownloads].
final downloadsServiceProvider = Provider<DownloadsService>(
  (ref) => RecordingDownloads(ref),
);

abstract class DownloadsService {
  /// Picks up downloads that went on while the app was closed.
  Future<void> start();

  /// Starts [request]. Private downloads leave no list entry (D17).
  Future<void> download(DownloadRequestEvent request, {required bool private});
  Future<void> pause(String taskId);
  Future<void> resume(String taskId);
  Future<void> cancel(String taskId);

  /// Opens a finished download with the app Android picks.
  Future<bool> open(DownloadItem item);

  ValueListenable<Map<String, LiveProgress>> get progress;
}

/// Records what was asked, writes list entries like the real service, moves
/// no bytes.
class RecordingDownloads implements DownloadsService {
  RecordingDownloads(this._ref);

  final Ref _ref;
  final requests = <DownloadRequestEvent>[];
  final opened = <String>[];
  final _progress = ValueNotifier<Map<String, LiveProgress>>(const {});

  @override
  ValueListenable<Map<String, LiveProgress>> get progress => _progress;

  @override
  Future<void> start() async {}

  @override
  Future<void> download(
    DownloadRequestEvent request, {
    required bool private,
  }) async {
    requests.add(request);
    if (private) return;
    await _ref
        .read(libraryProvider)
        .putDownload(
          DownloadItem(
            taskId: 'task-${requests.length}',
            url: request.url,
            fileName: request.fileName,
            mimeType: request.mimeType,
            totalBytes: request.size,
            status: DownloadStatus.running,
            startedAt: _ref.read(clockProvider)(),
          ),
        );
  }

  @override
  Future<void> pause(String taskId) => _set(taskId, DownloadStatus.paused);

  @override
  Future<void> resume(String taskId) => _set(taskId, DownloadStatus.running);

  @override
  Future<void> cancel(String taskId) => _set(taskId, DownloadStatus.canceled);

  Future<void> _set(String taskId, DownloadStatus status) async {
    final library = _ref.read(libraryProvider);
    final item = (await library.downloads())
        .where((d) => d.taskId == taskId)
        .firstOrNull;
    if (item != null) await library.putDownload(item.copyWith(status: status));
  }

  @override
  Future<bool> open(DownloadItem item) async {
    opened.add(item.taskId);
    return true;
  }
}

/// [DownloadsService] on `background_downloader`: a notification with
/// progress, pause and resume, cookies and user agent of the page so
/// downloads behind a login work, then a move into Download.
class BackgroundDownloadsService implements DownloadsService {
  BackgroundDownloadsService(this._ref);

  final Ref _ref;
  final _progress = ValueNotifier<Map<String, LiveProgress>>(const {});
  final _tasks = <String, DownloadTask>{};
  final _private = <String>{};
  StreamSubscription<TaskUpdate>? _sub;
  StreamSubscription<BridgeEvent>? _actions;
  var _started = false;

  Library get _library => _ref.read(libraryProvider);
  DateTime _now() => _ref.read(clockProvider)();

  @override
  ValueListenable<Map<String, LiveProgress>> get progress => _progress;

  @override
  Future<void> start() async {
    if (_started) return;
    _started = true;
    final downloader = FileDownloader();
    // Running and paused downloads get our own ongoing notification, which
    // can be a Live Update (`LiveUpdates.kt`); the downloader's own would
    // double it and cannot be promoted.
    downloader.configureNotification(
      complete: const TaskNotification('{filename}', 'Download'),
      error: const TaskNotification('{filename}', '✕'),
      tapOpensFile: true,
    );
    _sub = downloader.updates.listen(_onUpdate);
    _actions = HorizontWebKit.events.listen((event) {
      if (event is LiveActionEvent) _onLiveAction(event);
    });
    await downloader.start(autoCleanDatabase: true);
    // Downloads the list still shows as running but the downloader no longer
    // knows (the app was killed) are marked failed.
    final known = {
      for (final r in await downloader.database.allRecords()) r.taskId,
    };
    for (final item in await _library.downloads()) {
      if (item.active && !known.contains(item.taskId)) {
        await _library.putDownload(
          item.copyWith(status: DownloadStatus.failed, finishedAt: _now()),
        );
      }
    }
  }

  @override
  Future<void> download(
    DownloadRequestEvent request, {
    required bool private,
  }) async {
    await start();
    // Android 13+ shows the progress notification only with permission.
    unawaited(
      HorizontWebKit.requestPermissions(const [
        'android.permission.POST_NOTIFICATIONS',
      ]),
    );
    final bytes = request.bytes;
    if (bytes != null) {
      await _saveBytes(request, bytes, private: private);
      return;
    }
    final cookies =
        request.cookies ?? await HorizontWebKit.cookies(request.url.toString());
    final task = DownloadTask(
      url: request.url.toString(),
      filename: request.fileName,
      headers: {
        if (request.userAgent.isNotEmpty) 'User-Agent': request.userAgent,
        if (cookies != null && cookies.isNotEmpty) 'Cookie': cookies,
        if (request.referer != null) 'Referer': request.referer.toString(),
      },
      baseDirectory: BaseDirectory.applicationSupport,
      directory: 'downloads',
      updates: Updates.statusAndProgress,
      allowPause: true,
      retries: 2,
      transferHints: const {TransferHint.userInitiated},
    );
    _tasks[task.taskId] = task;
    if (private) {
      _private.add(task.taskId);
    } else {
      await _library.putDownload(
        DownloadItem(
          taskId: task.taskId,
          url: request.url,
          fileName: request.fileName,
          mimeType: request.mimeType,
          totalBytes: request.size,
          status: DownloadStatus.waiting,
          startedAt: _now(),
        ),
      );
    }
    await FileDownloader().enqueue(task);
  }

  /// `blob:` and `data:` downloads: the bytes are here already.
  Future<void> _saveBytes(
    DownloadRequestEvent request,
    Uint8List bytes, {
    required bool private,
  }) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/${request.fileName}');
    await file.writeAsBytes(bytes, flush: true);
    final saved = await FileDownloader().moveFileToSharedStorage(
      file.path,
      SharedStorage.downloads,
      mimeType: request.mimeType.isEmpty ? null : request.mimeType,
    );
    if (private) return;
    final now = _now();
    await _library.putDownload(
      DownloadItem(
        taskId: 'bytes-${now.microsecondsSinceEpoch}',
        url: request.url.scheme == 'data'
            ? Uri(scheme: 'data', path: request.mimeType)
            : request.referer ?? request.url,
        fileName: request.fileName,
        mimeType: request.mimeType,
        totalBytes: bytes.length,
        receivedBytes: bytes.length,
        status: saved == null ? DownloadStatus.failed : DownloadStatus.done,
        startedAt: now,
        finishedAt: now,
        savedUri: saved,
      ),
    );
  }

  Future<void> _onUpdate(TaskUpdate update) async {
    final id = update.task.taskId;
    switch (update) {
      case TaskProgressUpdate(
        :final progress,
        :final expectedFileSize,
        :final timeRemaining,
      ):
        if (progress < 0) return;
        final live = LiveProgress(
          fraction: progress,
          remaining: timeRemaining.isNegative ? null : timeRemaining,
          expectedBytes: expectedFileSize > 0 ? expectedFileSize : null,
        );
        _progress.value = {..._progress.value, id: live};
        _showLive(update.task, live, paused: false);
      case TaskStatusUpdate(:final status):
        if (status.isFinalState) {
          _progress.value = {..._progress.value}..remove(id);
          unawaited(HorizontWebKit.liveCancel(liveNotificationId(id)));
        } else if (status == TaskStatus.paused) {
          _showLive(update.task, _progress.value[id], paused: true);
        } else if (status == TaskStatus.running) {
          _showLive(update.task, _progress.value[id], paused: false);
        }
        await _onStatus(update, status);
    }
  }

  void _showLive(Task task, LiveProgress? live, {required bool paused}) {
    final strings = LiveStrings.forLocale(
      PlatformDispatcher.instance.locale.languageCode,
    );
    final id = task.taskId;
    final percent = live == null || live.fraction < 0
        ? -1
        : (live.fraction * 100).round();
    unawaited(
      HorizontWebKit.liveShow(
        id: liveNotificationId(id),
        // A private download must not show its name on the lock screen.
        title: _private.contains(id) ? strings.privateDownload : task.filename,
        text: strings.text(percent, live?.remaining, paused: paused),
        progress: percent,
        chip: percent < 0 ? null : '$percent%',
        actions: [
          (
            paused ? strings.resume : strings.pause,
            paused ? 'resume' : 'pause',
          ),
          (strings.cancel, 'cancel'),
        ],
        payload: id,
      ),
    );
  }

  void _onLiveAction(LiveActionEvent event) {
    final id = event.payload;
    switch (event.action) {
      case 'pause':
        unawaited(pause(id));
      case 'resume':
        unawaited(resume(id));
      case 'cancel':
        unawaited(cancel(id));
    }
  }

  Future<void> _onStatus(TaskStatusUpdate update, TaskStatus status) async {
    final id = update.task.taskId;
    final private = _private.contains(id);
    String? saved;
    if (status == TaskStatus.complete && update.task is DownloadTask) {
      saved = await FileDownloader().moveToSharedStorage(
        update.task as DownloadTask,
        SharedStorage.downloads,
      );
    }
    if (private) {
      if (status.isFinalState) _private.remove(id);
      return;
    }
    final item = (await _library.downloads())
        .where((d) => d.taskId == id)
        .firstOrNull;
    if (item == null) return;
    final live = _progress.value[id];
    final mapped = switch (status) {
      TaskStatus.enqueued ||
      TaskStatus.waitingToRetry => DownloadStatus.waiting,
      TaskStatus.running => DownloadStatus.running,
      TaskStatus.paused => DownloadStatus.paused,
      TaskStatus.complete =>
        saved == null ? DownloadStatus.failed : DownloadStatus.done,
      TaskStatus.canceled => DownloadStatus.canceled,
      TaskStatus.failed || TaskStatus.notFound => DownloadStatus.failed,
    };
    final size = live?.expectedBytes ?? item.totalBytes;
    await _library.putDownload(
      item.copyWith(
        status: mapped,
        totalBytes: size,
        receivedBytes: mapped == DownloadStatus.done
            ? size ?? item.receivedBytes
            : size == null || live == null
            ? item.receivedBytes
            : (live.fraction * size).round(),
        finishedAt: status.isFinalState ? _now() : null,
        savedUri: saved,
      ),
    );
  }

  Future<DownloadTask?> _task(String taskId) async {
    final known = _tasks[taskId];
    if (known != null) return known;
    final task = await FileDownloader().taskForId(taskId);
    return task is DownloadTask ? task : null;
  }

  @override
  Future<void> pause(String taskId) async {
    final task = await _task(taskId);
    if (task != null) await FileDownloader().pause(task);
  }

  @override
  Future<void> resume(String taskId) async {
    final task = await _task(taskId);
    if (task != null) await FileDownloader().resume(task);
  }

  @override
  Future<void> cancel(String taskId) =>
      FileDownloader().cancelTaskWithId(taskId);

  @override
  Future<bool> open(DownloadItem item) async {
    final path = item.savedUri;
    if (path == null) return false;
    return FileDownloader().openFile(
      filePath: path,
      mimeType: item.mimeType.isEmpty ? null : item.mimeType,
    );
  }

  void dispose() {
    unawaited(_sub?.cancel());
    unawaited(_actions?.cancel());
  }
}

/// The id of the notification for download [taskId]; positive, stable.
@visibleForTesting
int liveNotificationId(String taskId) => taskId.hashCode & 0x7fffffff;

/// Words of the download notification. Plain strings because the service has
/// no `BuildContext`; the app has two languages (en, de).
@immutable
class LiveStrings {
  const LiveStrings({
    required this.pause,
    required this.resume,
    required this.cancel,
    required this.paused,
    required this.privateDownload,
    required this.left,
  });

  factory LiveStrings.forLocale(String language) => language == 'de'
      ? const LiveStrings(
          pause: 'Pause',
          resume: 'Weiter',
          cancel: 'Abbrechen',
          paused: 'Pausiert',
          privateDownload: 'Privater Download',
          left: 'übrig',
        )
      : const LiveStrings(
          pause: 'Pause',
          resume: 'Resume',
          cancel: 'Cancel',
          paused: 'Paused',
          privateDownload: 'Private download',
          left: 'left',
        );

  final String pause;
  final String resume;
  final String cancel;
  final String paused;
  final String privateDownload;
  final String left;

  /// "42 % · 1 min left"; [percent] is negative while unknown.
  String text(int percent, Duration? remaining, {required bool paused}) {
    final parts = [
      if (percent >= 0) '$percent %',
      if (paused) this.paused,
      if (!paused && remaining != null) '${_duration(remaining)} $left',
    ];
    return parts.join(' · ');
  }

  static String _duration(Duration d) {
    if (d.inHours >= 1) return '${d.inHours} h ${d.inMinutes % 60} min';
    if (d.inMinutes >= 1) return '${d.inMinutes} min';
    return '${d.inSeconds.clamp(1, 59)} s';
  }
}
