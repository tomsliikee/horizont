import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/app_localizations.dart';
import '../theme/type.dart';
import '../ui/buttons.dart';
import '../ui/floating_surface.dart';
import 'browser_providers.dart';
import 'web_engine.dart';

/// Find in page (D18): the bar becomes a pill with the input, "3 of 12",
/// up, down and close. The matches are highlighted by the web view itself.
class FindBar extends ConsumerStatefulWidget {
  const FindBar({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  ConsumerState<FindBar> createState() => _FindBarState();
}

class _FindBarState extends ConsumerState<FindBar> {
  final _text = TextEditingController();
  final _focus = FocusNode();
  StreamSubscription<EngineEvent>? _sub;
  Timer? _debounce;
  var _active = 0;
  var _count = 0;

  WebEngine get _engine => ref.read(webEngineProvider);

  @override
  void initState() {
    super.initState();
    _sub = _engine.events.listen((event) {
      if (event is FindResultEvent && mounted) {
        setState(() {
          _active = event.active;
          _count = event.count;
        });
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    unawaited(_sub?.cancel());
    unawaited(_engine.clearFind());
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 120), () {
      unawaited(_engine.find(text));
      if (text.isEmpty && mounted) {
        setState(() {
          _active = 0;
          _count = 0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final hasText = _text.text.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: FloatingSurface(
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              const SizedBox(width: 18),
              SymbolIcon(
                HIcons.findInPage,
                size: 20,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _text,
                  focusNode: _focus,
                  onChanged: _onChanged,
                  onSubmitted: (_) {
                    unawaited(_engine.findNext());
                    _focus.requestFocus();
                  },
                  textInputAction: TextInputAction.search,
                  cursorColor: scheme.primary,
                  style: HorizontType.subtitle
                      .withWeight(500)
                      .copyWith(color: scheme.onSurface),
                  decoration: InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: l10n.findPlaceholder,
                    hintStyle: HorizontType.subtitle.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              if (hasText)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    _count == 0
                        ? l10n.noMatches
                        : l10n.findCount(_active, _count),
                    style: HorizontType.label.copyWith(
                      color: _count == 0
                          ? scheme.error
                          : scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              RoundButton(
                icon: HIcons.keyboardUp,
                semanticLabel: l10n.previousMatch,
                size: 44,
                iconSize: 24,
                look: ButtonLook.plain,
                onTap: _count > 0
                    ? () => unawaited(_engine.findNext(forward: false))
                    : null,
              ),
              RoundButton(
                icon: HIcons.keyboardDown,
                semanticLabel: l10n.nextMatch,
                size: 44,
                iconSize: 24,
                look: ButtonLook.plain,
                onTap: _count > 0 ? () => unawaited(_engine.findNext()) : null,
              ),
              RoundButton(
                icon: HIcons.close,
                semanticLabel: l10n.closeFind,
                size: 44,
                iconSize: 22,
                look: ButtonLook.highest,
                onTap: widget.onClose,
              ),
              const SizedBox(width: 6),
            ],
          ),
        ),
      ),
    );
  }
}
