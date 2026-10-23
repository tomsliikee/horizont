/// The file name of a download (PLAN 4.3): from `Content-Disposition`
/// (`filename*=UTF-8''…` before `filename="…"`), else the last path segment,
/// else "download" with an extension guessed from the MIME type. Characters
/// a file system refuses are replaced.
String downloadFileName({
  required Uri url,
  String contentDisposition = '',
  String mimeType = '',
}) {
  String? name = _fromDisposition(contentDisposition);
  if (name == null || name.isEmpty) {
    final segments = url.pathSegments.where((s) => s.isNotEmpty);
    if (url.scheme != 'data' && url.scheme != 'blob' && segments.isNotEmpty) {
      name = segments.last;
    }
  }
  name = _clean(name ?? '');
  if (name.isEmpty) name = 'download';
  if (!name.contains('.')) {
    final ext = _extensions[mimeType.split(';').first.trim().toLowerCase()];
    if (ext != null) name = '$name.$ext';
  }
  return name;
}

String? _fromDisposition(String header) {
  if (header.isEmpty) return null;
  final star = RegExp(
    r"filename\*\s*=\s*([\w-]+)''([^;]+)",
    caseSensitive: false,
  ).firstMatch(header);
  if (star != null) {
    try {
      return Uri.decodeComponent(star.group(2)!.trim().replaceAll('"', ''));
    } on ArgumentError {
      // Fall through to the plain form.
    }
  }
  final quoted = RegExp(
    r'filename\s*=\s*"([^"]*)"',
    caseSensitive: false,
  ).firstMatch(header);
  if (quoted != null) return quoted.group(1);
  final bare = RegExp(
    r'filename\s*=\s*([^;]+)',
    caseSensitive: false,
  ).firstMatch(header);
  return bare?.group(1)?.trim();
}

String _clean(String name) {
  var n = name;
  try {
    n = Uri.decodeComponent(n);
  } on ArgumentError {
    // Keep it as it was.
  }
  n = n.replaceAll(RegExp(r'[\\/:*?"<>|\x00-\x1f]'), '_').trim();
  // No hidden files, no names that are only dots.
  n = n.replaceFirst(RegExp(r'^\.+'), '');
  if (n.length > 120) {
    final dot = n.lastIndexOf('.');
    final ext = dot > 0 && n.length - dot <= 10 ? n.substring(dot) : '';
    n = n.substring(0, 120 - ext.length) + ext;
  }
  return n;
}

const _extensions = {
  'application/pdf': 'pdf',
  'application/zip': 'zip',
  'application/json': 'json',
  'application/vnd.android.package-archive': 'apk',
  'application/msword': 'doc',
  'application/vnd.openxmlformats-officedocument.wordprocessingml.document':
      'docx',
  'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet': 'xlsx',
  'application/vnd.openxmlformats-officedocument.presentationml.presentation':
      'pptx',
  'audio/mpeg': 'mp3',
  'image/jpeg': 'jpg',
  'image/png': 'png',
  'image/gif': 'gif',
  'image/webp': 'webp',
  'image/svg+xml': 'svg',
  'text/plain': 'txt',
  'text/html': 'html',
  'text/csv': 'csv',
  'video/mp4': 'mp4',
};
