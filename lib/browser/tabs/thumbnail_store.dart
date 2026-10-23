import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

/// The tab pictures on disk, in the app's private files. Each write gets a new
/// file name, so a picture that changed is not served from the image cache.
class ThumbnailStore {
  ThumbnailStore([Future<Directory> Function()? directory])
    : _directory = directory ?? _defaultDirectory;

  final Future<Directory> Function() _directory;

  static Future<Directory> _defaultDirectory() async {
    final base = await getApplicationSupportDirectory();
    return Directory('${base.path}/thumbs').create(recursive: true);
  }

  /// Writes [bytes] as the picture of [tabId] and returns its path; the
  /// previous picture of that tab is removed.
  Future<String> write(String tabId, Uint8List bytes) async {
    final dir = await _directory();
    await delete(tabId);
    final file = File(
      '${dir.path}/$tabId-${DateTime.now().millisecondsSinceEpoch}.webp',
    );
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  Future<void> delete(String tabId) async {
    final dir = await _directory();
    if (!dir.existsSync()) return;
    for (final entity in dir.listSync()) {
      final name = entity.uri.pathSegments.last;
      if (entity is File && name.startsWith('$tabId-')) {
        await entity.delete();
      }
    }
  }
}
