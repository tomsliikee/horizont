import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import '../../ui/address_pill.dart';
import '../../ui/buttons.dart';
import '../../ui/floating_surface.dart';
import '../web_engine.dart';
import 'bar_actions.dart';

/// Layout "kompakt" (`P:159`–`P:172`): a glass back button, a glass pill with
/// the address and reload, a glass menu button. Bottom 28, sides 16, gap 8.
class CompactBar extends StatelessWidget {
  const CompactBar({super.key, required this.page, required this.actions});

  final PageState page;
  final BarActions actions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final onStart = page.url == null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
      child: Row(
        spacing: 8,
        children: [
          Opacity(
            opacity: actions.back == null ? 0.38 : 1,
            child: RoundButton(
              icon: HIcons.arrowBack,
              semanticLabel: l10n.back,
              size: 56,
              onTap: actions.back,
            ),
          ),
          Expanded(
            child: FloatingSurface(
              child: SizedBox(
                height: 56,
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    Expanded(
                      child: AddressPill(
                        text: page.displayHost,
                        placeholder: l10n.searchOrEnterAddress,
                        secure: page.secure,
                        onTap: actions.search,
                        progress: page.loading ? page.progress : null,
                      ),
                    ),
                    RoundButton(
                      icon: HIcons.refresh,
                      semanticLabel: l10n.reload,
                      size: 48,
                      iconSize: 22,
                      look: ButtonLook.plain,
                      onTap: onStart ? null : actions.reload,
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
              ),
            ),
          ),
          RoundButton(
            icon: HIcons.menu,
            semanticLabel: l10n.menu,
            size: 56,
            onTap: actions.menu,
            onLongPress: actions.tabs,
          ),
        ],
      ),
    );
  }
}
