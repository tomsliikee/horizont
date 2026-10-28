import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import '../../platform/horizont_webkit.dart';
import '../../ui/buttons.dart';
import '../../ui/haptics.dart';
import '../../ui/tiles.dart';

/// The row of quick actions under the search: a private tab, a QR code, a
/// spoken search, and a link from the clipboard while it holds one.
class QuickChips extends StatefulWidget {
  const QuickChips({
    super.key,
    required this.onPrivate,
    required this.onOpen,
    required this.onSearch,
  });

  final VoidCallback onPrivate;
  final ValueChanged<Uri> onOpen;

  /// Opens the search with the words given.
  final ValueChanged<String> onSearch;

  @override
  State<QuickChips> createState() => _QuickChipsState();
}

class _QuickChipsState extends State<QuickChips> with WidgetsBindingObserver {
  var _clipLink = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_checkClip());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(_checkClip());
  }

  Future<void> _checkClip() async {
    final has = await HorizontWebKit.clipHasLink();
    if (mounted && has != _clipLink) setState(() => _clipLink = has);
  }

  /// [text] as a web address when it is one.
  static Uri? _link(String text) {
    final uri = Uri.tryParse(text.trim());
    return uri != null &&
            (uri.scheme == 'http' || uri.scheme == 'https') &&
            uri.host.isNotEmpty
        ? uri
        : null;
  }

  Future<void> _scan() async {
    final text = await HorizontWebKit.scanQr();
    if (text == null || text.trim().isEmpty || !mounted) return;
    Haptics.play(Haptic.confirm);
    final link = _link(text);
    link != null ? widget.onOpen(link) : widget.onSearch(text.trim());
  }

  Future<void> _voice() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.maybeOf(context);
    try {
      final words = await HorizontWebKit.voiceSearch();
      if (words != null && words.isNotEmpty && mounted) widget.onSearch(words);
    } on VoiceUnavailable {
      Haptics.play(Haptic.reject);
      messenger?.showSnackBar(SnackBar(content: Text(l10n.voiceUnavailable)));
    }
  }

  Future<void> _paste() async {
    final text = await HorizontWebKit.clipText();
    if (text == null || !mounted) return;
    final link = _link(text);
    link != null ? widget.onOpen(link) : widget.onSearch(text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        spacing: 8,
        children: [
          QuickChip(
            icon: HIcons.visibilityOff,
            label: l10n.quickPrivate,
            onTap: widget.onPrivate,
          ),
          QuickChip(
            icon: HIcons.qrCodeScanner,
            label: l10n.quickScan,
            onTap: () => unawaited(_scan()),
          ),
          QuickChip(
            icon: HIcons.mic,
            label: l10n.quickVoice,
            onTap: () => unawaited(_voice()),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            child: _clipLink
                ? QuickChip(
                    icon: HIcons.contentPaste,
                    label: l10n.quickPasteLink,
                    selected: true,
                    onTap: () => unawaited(_paste()),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
