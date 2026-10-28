import 'dart:async';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../browser/browser_providers.dart';
import '../browser/tabs/tab_session.dart';
import '../browser/tabs/tabs_notifier.dart';
import '../browser/web_engine.dart';
import '../data/library_providers.dart';
import '../features/downloads/downloads_page.dart' show fileSize;
import '../l10n/app_localizations.dart';
import '../platform/downloads_service.dart';
import '../platform/horizont_webkit.dart';
import '../theme/extensions.dart';
import '../theme/type.dart';
import '../ui/buttons.dart';
import '../ui/haptics.dart';
import '../ui/lists.dart';
import '../ui/tiles.dart';
import 'providers.dart';

/// Answers what a page asks of the browser (PLAN 4.2–4.5, M11): links to
/// other apps, downloads, JavaScript dialogs, logins, permissions, file
/// pickers and full-screen video. Requests from tabs in the background get
/// the safe answer without asking.
class EngineRequests {
  EngineRequests(this.context, this.ref, {required this.onDownloadsTap});

  final BuildContext context;
  final WidgetRef ref;
  final VoidCallback onDownloadsTap;

  AppLocalizations get _l10n => AppLocalizations.of(context);

  void _say(String text, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          action: action,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> handle(TabEvent tabEvent) async {
    final event = tabEvent.event;
    final tabs = ref.read(tabsProvider);
    final active = tabs.activeId == tabEvent.tabId;
    final private = tabs.byId(tabEvent.tabId)?.isPrivate ?? false;
    switch (event) {
      case ExternalLinkEvent(:final uri):
        if (active) await _external(uri);
      case DownloadRequestEvent():
        final tab = tabs.byId(tabEvent.tabId);
        // The tab was opened for the file itself (a link from another app):
        // it must not keep the file's address, or every start asks again.
        final forFile =
            tab != null &&
            (tab.url == event.url ||
                event.referer == null ||
                event.referer == event.url);
        final notifier = ref.read(tabsProvider.notifier);
        final external = forFile && notifier.isExternal(tabEvent.tabId);
        if (forFile) notifier.updatePage(tabEvent.tabId, clearUrl: true);
        await _download(event, private: private);
        if (!forFile || !active) return;
        unawaited(ref.read(webEngineProvider).goToStart());
        if (external) {
          // Back to the app that sent the link, as after back.
          notifier.close(tabEvent.tabId);
          unawaited(SystemNavigator.pop());
        }
      case JsDialogEvent():
        if (!active) {
          event.answer.complete(
            event.kind == JsDialogKind.confirm ? false : null,
          );
        } else {
          await _jsDialog(event);
        }
      case HttpAuthEvent():
        if (!active) {
          event.answer.complete(null);
        } else {
          await _auth(event);
        }
      case PermissionEvent():
        if (!active) {
          event.answer.complete(false);
        } else {
          await _permission(event, private: private);
        }
      case FileChooserEvent():
        if (!active) {
          event.answer.complete(const []);
        } else {
          await _files(event);
        }
      case FullscreenEvent(:final view, :final exit):
        if (active) await _fullscreen(view, exit);
      default:
        break;
    }
  }

  Future<void> _external(Uri uri) async {
    final target = switch (uri.scheme) {
      'mailto' => uri.path,
      'tel' => uri.path,
      'intent' => uri.toString().split('#').first.replaceFirst('intent:', ''),
      _ => uri.scheme,
    };
    final ok = await _ask(
      title: _l10n.openInOtherApp,
      body: _l10n.openInOtherAppBody(target),
      action: _l10n.open,
    );
    if (!ok) return;
    final result = await HorizontWebKit.openExternal(uri.toString());
    if (result.opened) return;
    final fallback = result.fallback == null
        ? null
        : Uri.tryParse(result.fallback!);
    if (fallback != null &&
        (fallback.scheme == 'https' || fallback.scheme == 'http')) {
      await ref.read(webEngineProvider).load(fallback);
    } else {
      _say(_l10n.noAppForLink);
    }
  }

  Future<void> _download(
    DownloadRequestEvent event, {
    required bool private,
  }) async {
    final ask = ref.read(settingsProvider).askBeforeDownload || private;
    if (ask) {
      final ok = await _confirmDownload(event, private: private);
      if (!ok) return;
    }
    await ref.read(downloadsServiceProvider).download(event, private: private);
    if (!context.mounted) return;
    Haptics.play(Haptic.confirm);
    _say(
      _l10n.downloadStarted,
      action: private
          ? null
          : SnackBarAction(label: _l10n.showAll, onPressed: onDownloadsTap),
    );
  }

  Future<bool> _confirmDownload(
    DownloadRequestEvent event, {
    required bool private,
  }) async {
    final scheme = Theme.of(context).colorScheme;
    final host = (event.referer ?? event.url).host;
    final size = event.size == null
        ? _l10n.unknownSize
        : fileSize(event.size!, context);
    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: scheme.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const DragHandle(),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
                child: Text(
                  _l10n.downloadAsk,
                  style: HorizontType.headline.copyWith(
                    color: scheme.onSurface,
                  ),
                ),
              ),
              ListGroup(
                rows: [
                  ListRow(
                    leading: IconWell(
                      icon: HIcons.download,
                      fill: scheme.primaryContainer,
                      ink: scheme.onPrimaryContainer,
                    ),
                    title: event.fileName,
                    subtitle: [size, if (host.isNotEmpty) host].join(' · '),
                  ),
                ],
              ),
              if (private)
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 12, 4, 0),
                  child: Text(
                    _l10n.privateDownloadWarning,
                    style: HorizontType.aside.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                spacing: 8,
                children: [
                  Expanded(
                    child: PillButton(
                      label: _l10n.cancel,
                      height: 52,
                      onTap: () => Navigator.of(context).pop(false),
                    ),
                  ),
                  Expanded(
                    child: PillButton(
                      icon: HIcons.download,
                      label: _l10n.download,
                      height: 52,
                      look: ButtonLook.primary,
                      onTap: () => Navigator.of(context).pop(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return result ?? false;
  }

  String get _host => ref.read(pageStateProvider).displayHost;

  Future<void> _jsDialog(JsDialogEvent event) async {
    final controller = TextEditingController(text: event.defaultText);
    final result = await showDialog<Object?>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(_l10n.pageSays(_host)),
        content: event.kind == JsDialogKind.prompt
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.message),
                  TextField(controller: controller, autofocus: true),
                ],
              )
            : SingleChildScrollView(child: Text(event.message)),
        actions: [
          if (event.kind != JsDialogKind.alert)
            TextButton(
              onPressed: () =>
                  Navigator.of(context)
                      .pop(event.kind == JsDialogKind.confirm ? false : null),
              child: Text(_l10n.cancel),
            ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(switch (event.kind) {
              JsDialogKind.alert => null,
              JsDialogKind.confirm => true,
              JsDialogKind.prompt => controller.text,
            }),
            child: Text(_l10n.ok),
          ),
        ],
      ),
    );
    controller.dispose();
    if (!event.answer.isCompleted) event.answer.complete(result);
  }

  Future<void> _auth(HttpAuthEvent event) async {
    final user = TextEditingController();
    final password = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_l10n.signInTo(event.host)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (event.realm != null && event.realm!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(event.realm!),
              ),
            TextField(
              controller: user,
              autofocus: true,
              autofillHints: const [AutofillHints.username],
              decoration: InputDecoration(labelText: _l10n.username),
            ),
            TextField(
              controller: password,
              obscureText: true,
              autofillHints: const [AutofillHints.password],
              decoration: InputDecoration(labelText: _l10n.password),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(_l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(_l10n.signIn),
          ),
        ],
      ),
    );
    event.answer.complete(ok == true ? (user.text, password.text) : null);
    user.dispose();
    password.dispose();
  }

  static const _android = {
    SitePermissionKind.camera: 'android.permission.CAMERA',
    SitePermissionKind.microphone: 'android.permission.RECORD_AUDIO',
    SitePermissionKind.location: 'android.permission.ACCESS_FINE_LOCATION',
  };

  Future<void> _permission(
    PermissionEvent event, {
    required bool private,
  }) async {
    final library = ref.read(libraryProvider);
    final origin = event.origin;
    // Asked before: the answer is kept per site and kind (not in private).
    bool? decided;
    if (!private) {
      for (final kind in event.kinds) {
        final stored = await library.permission(origin, kind);
        if (stored == null) {
          decided = null;
          break;
        }
        decided = (decided ?? true) && stored;
      }
    }
    var allow = decided;
    if (allow == null) {
      final what = event.kinds
          .map(
            (k) => switch (k) {
              SitePermissionKind.camera => _l10n.camera,
              SitePermissionKind.microphone => _l10n.microphone,
              SitePermissionKind.location => _l10n.location,
            },
          )
          .join(' ${_l10n.and} ');
      final host = Uri.tryParse(origin)?.host ?? origin;
      allow = await _ask(
        title: _l10n.permissionAsk(host, what),
        body: '',
        action: _l10n.allow,
        cancel: _l10n.dontAllow,
        icon: event.kinds.contains(SitePermissionKind.location)
            ? HIcons.locationOn
            : event.kinds.contains(SitePermissionKind.camera)
            ? HIcons.videocam
            : HIcons.mic,
      );
      if (!private) {
        for (final kind in event.kinds) {
          await library.setPermission(origin, kind, allow);
        }
      }
    }
    if (allow) {
      final granted = await HorizontWebKit.requestPermissions([
        for (final k in event.kinds) _android[k]!,
      ]);
      allow = granted.values.every((g) => g);
    }
    event.answer.complete(allow);
  }

  Future<void> _files(FileChooserEvent event) async {
    final mimes = event.acceptTypes.where((t) => t.contains('/')).toList();
    final extensions = event.acceptTypes
        .where((t) => t.startsWith('.'))
        .map((t) => t.substring(1))
        .toList();
    final group = XTypeGroup(
      mimeTypes: mimes.isEmpty ? null : mimes,
      extensions: extensions.isEmpty ? null : extensions,
    );
    final groups = mimes.isEmpty && extensions.isEmpty
        ? const <XTypeGroup>[]
        : [group];
    try {
      final files = event.multiple
          ? await openFiles(acceptedTypeGroups: groups)
          : [?await openFile(acceptedTypeGroups: groups)];
      event.answer.complete([
        for (final f in files) Uri.file(f.path).toString(),
      ]);
    } on Object {
      event.answer.complete(const []);
    }
  }

  Future<void> _fullscreen(Widget view, VoidCallback exit) async {
    await SystemChrome.setPreferredOrientations(const []);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    if (!context.mounted) return;
    await Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 180),
        pageBuilder: (context, _, _) =>
            _FullscreenVideo(view: view, exit: exit),
        transitionsBuilder: (context, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  Future<bool> _ask({
    required String title,
    required String body,
    required String action,
    String? cancel,
    IconData? icon,
  }) async {
    final scheme = Theme.of(context).colorScheme;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: icon == null
            ? null
            : SymbolIcon(icon, size: 28, color: scheme.secondary),
        title: Text(title),
        content: body.isEmpty ? null : Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancel ?? _l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(action),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

/// A video in full screen until the page or back ends it; it may rotate.
class _FullscreenVideo extends StatefulWidget {
  const _FullscreenVideo({required this.view, required this.exit});

  final Widget view;
  final VoidCallback exit;

  @override
  State<_FullscreenVideo> createState() => _FullscreenVideoState();
}

class _FullscreenVideoState extends State<_FullscreenVideo> {
  StreamSubscription<TabEvent>? _sub;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sub ??= ProviderScope.containerOf(context, listen: false)
        .read(tabSessionProvider)
        .events
        .listen((e) {
          if (e.event is FullscreenExitEvent && mounted) {
            Navigator.of(context).maybePop();
          }
        });
  }

  @override
  void dispose() {
    unawaited(_sub?.cancel());
    widget.exit();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: HorizontColors.of(context).scrim.withValues(alpha: 1),
    child: widget.view,
  );
}
