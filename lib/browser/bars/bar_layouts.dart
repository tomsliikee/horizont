import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/extensions.dart';
import '../../theme/type.dart';
import '../../ui/address_pill.dart';
import '../../ui/buttons.dart';
import '../../ui/floating_surface.dart';
import '../../ui/progress_line.dart';
import '../../ui/squish.dart';
import '../../ui/tiles.dart';
import '../web_engine.dart';
import 'bar_actions.dart';

/// The parts of a bar layout: what floats at the bottom, what floats at the
/// top (expressiv, oben), and how much room the top part takes from the
/// page (`P:808`).
@immutable
class BarParts {
  const BarParts({required this.bottom, this.top, this.topReserve = 0});
  final Widget bottom;
  final Widget? top;
  final double topReserve;
}

/// The address as every layout shows it.
class _Address {
  _Address(BuildContext context, this.page, this.actions)
    : l10n = AppLocalizations.of(context);

  final PageState page;
  final BarActions actions;
  final AppLocalizations l10n;

  String get text => page.displayHost;
  String get placeholder => actions.privateMode
      ? l10n.privateSearchOrAddress
      : l10n.searchOrEnterAddress;
  IconData? get icon =>
      actions.privateMode && page.url == null ? HIcons.visibilityOff : null;
  double? get progress => page.loading ? page.progress : null;

  /// The second line of the card layout (`addrSub`, `P:1001`).
  String subtitle(String engine) {
    if (actions.privateMode && page.url == null) return l10n.notStored;
    if (page.url == null) return engine;
    final title = page.title.isEmpty ? page.displayHost : page.title;
    return page.secure
        ? l10n.secureSubtitle(title)
        : l10n.insecureSubtitle(title);
  }
}

Widget _dim(VoidCallback? action, Widget child) =>
    Opacity(opacity: action == null ? 0.38 : 1, child: child);

Widget _icon(
  IconData icon,
  String label,
  VoidCallback? onTap, {
  double size = 48,
  double iconSize = 24,
  VoidCallback? onLongPress,
  Key? key,
}) => _dim(
  onTap,
  RoundButton(
    key: key,
    icon: icon,
    semanticLabel: label,
    size: size,
    iconSize: iconSize,
    look: ButtonLook.plain,
    onTap: onTap,
    onLongPress: onLongPress,
  ),
);

Widget _tabsButton(BuildContext context, BarActions a) {
  final l10n = AppLocalizations.of(context);
  return Squish(
    semanticLabel: '${l10n.tabs}, ${a.tabCount}',
    onTap: a.tabs,
    child: SizedBox(
      width: 48,
      height: 48,
      child: Center(child: TabCountGlyph(count: a.tabCount)),
    ),
  );
}

/// Layout "kompakt" (`P:159`–`P:172`): glass back button, a glass pill with
/// reader, address and reload, glass menu button. Bottom 28, sides 16.
BarParts compactBar(BuildContext context, PageState page, BarActions a) {
  final l10n = AppLocalizations.of(context);
  final addr = _Address(context, page, a);
  return BarParts(
    bottom: Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
      child: Row(
        spacing: 8,
        children: [
          _dim(
            a.back,
            RoundButton(
              icon: HIcons.arrowBack,
              semanticLabel: l10n.back,
              size: 56,
              onTap: a.back,
            ),
          ),
          Expanded(
            child: FloatingSurface(
              key: a.addressKey,
              child: SizedBox(
                height: 56,
                child: Row(
                  children: [
                    const SizedBox(width: 4),
                    // On the start page the address needs the room.
                    if (page.url == null)
                      const SizedBox(width: 12)
                    else
                      _dim(
                        a.reader,
                        RoundButton(
                          icon: HIcons.chromeReaderMode,
                          semanticLabel: l10n.readerView,
                          size: 48,
                          iconSize: 22,
                          look: a.readerOn
                              ? ButtonLook.primary
                              : ButtonLook.plain,
                          onTap: a.reader,
                        ),
                      ),
                    Expanded(
                      child: AddressPill(
                        text: addr.text,
                        placeholder: addr.placeholder,
                        secure: page.secure,
                        icon: addr.icon,
                        onTap: a.search,
                        progress: addr.progress,
                      ),
                    ),
                    if (page.url == null)
                      const SizedBox(width: 12)
                    else
                      _icon(
                        HIcons.refresh,
                        l10n.reload,
                        a.reload,
                        iconSize: 22,
                      ),
                    const SizedBox(width: 4),
                  ],
                ),
              ),
            ),
          ),
          RoundButton(
            key: a.menuKey,
            icon: HIcons.menu,
            semanticLabel: l10n.menu,
            size: 56,
            onTap: a.menu,
            onLongPress: a.tabs,
          ),
        ],
      ),
    ),
  );
}

/// Layout "zweireihig" (`P:175`–`P:189`): the address pill 52 above a
/// toolbar 64 with back, forward, share, library and tabs. Bottom 24.
BarParts twoRowBar(BuildContext context, PageState page, BarActions a) {
  final l10n = AppLocalizations.of(context);
  final addr = _Address(context, page, a);
  return BarParts(
    bottom: Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          FloatingSurface(
            key: a.addressKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AddressPill(
                height: 52,
                text: addr.text,
                placeholder: addr.placeholder,
                secure: page.secure,
                icon: addr.icon,
                onTap: a.search,
                progress: addr.progress,
              ),
            ),
          ),
          FloatingSurface(
            borderRadius: BorderRadius.circular(32),
            child: SizedBox(
              height: 64,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: _icon(HIcons.arrowBack, l10n.back, a.back),
                  ),
                  _icon(HIcons.arrowForward, l10n.forward, a.forward),
                  // The share icon opens the menu, whose first tile shares
                  // (`P:183`).
                  _icon(HIcons.iosShare, l10n.menu, a.menu, key: a.menuKey),
                  _icon(HIcons.book2, l10n.library, a.library),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _tabsButton(context, a),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Layout "expressiv" (`P:192`–`P:208`): an address chip 44 at the top, a
/// toolbar 64 with back, forward, tabs and menu, and the search FAB 64 with
/// radius 20 in `tertiaryContainer`.
BarParts expressiveBar(BuildContext context, PageState page, BarActions a) {
  final l10n = AppLocalizations.of(context);
  final scheme = Theme.of(context).colorScheme;
  final addr = _Address(context, page, a);
  return BarParts(
    topReserve: 60,
    top: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: DecoratedBox(
          key: a.addressKey,
          decoration: BoxDecoration(
            color: HorizontColors.of(context).glass,
            borderRadius: BorderRadius.circular(22),
            boxShadow: HorizontShadows.of(context).button,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: AddressPill(
              height: 44,
              small: true,
              text: addr.text,
              placeholder: addr.placeholder,
              secure: page.secure,
              icon: addr.icon,
              onTap: a.search,
              progress: addr.progress,
            ),
          ),
        ),
      ),
    ),
    bottom: Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
      child: Row(
        spacing: 8,
        children: [
          Expanded(
            child: FloatingSurface(
              borderRadius: BorderRadius.circular(32),
              child: SizedBox(
                height: 64,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _icon(HIcons.arrowBack, l10n.back, a.back),
                    _icon(HIcons.arrowForward, l10n.forward, a.forward),
                    _tabsButton(context, a),
                    _icon(HIcons.moreVert, l10n.menu, a.menu, key: a.menuKey),
                  ],
                ),
              ),
            ),
          ),
          Squish(
            semanticLabel: l10n.search,
            onTap: a.search,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: scheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(20),
                boxShadow: HorizontShadows.of(context).floating,
              ),
              alignment: Alignment.center,
              child: SymbolIcon(
                HIcons.search,
                size: 28,
                color: scheme.onTertiaryContainer,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Layout "oben" (`P:211`–`P:225`): the address field 56 at the top with a
/// mic well; at the bottom a navigation bar 64 with a filled "Seite" or
/// "Start" pill and three icons.
BarParts topBar(BuildContext context, PageState page, BarActions a) {
  final l10n = AppLocalizations.of(context);
  final scheme = Theme.of(context).colorScheme;
  final addr = _Address(context, page, a);
  final onPage = page.url != null;
  return BarParts(
    topReserve: 72,
    top: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: FloatingSurface(
        key: a.addressKey,
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              const SizedBox(width: 16),
              Expanded(
                child: AddressPill(
                  height: 56,
                  centered: false,
                  text: addr.text,
                  placeholder: addr.placeholder,
                  secure: page.secure,
                  icon: addr.icon,
                  onTap: a.search,
                  progress: addr.progress,
                ),
              ),
              Squish(
                semanticLabel: l10n.reload,
                onTap: onPage ? a.reload : a.search,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHigh,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: SymbolIcon(
                    onPage ? HIcons.refresh : HIcons.mic,
                    size: 20,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    ),
    bottom: Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
      child: FloatingSurface(
        borderRadius: BorderRadius.circular(32),
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: PillButton(
                  icon: onPage ? HIcons.arrowBack : HIcons.home,
                  label: onPage ? l10n.pageNav : l10n.startNav,
                  look: ButtonLook.primary,
                  onTap: onPage ? (a.back ?? a.home) : a.search,
                ),
              ),
              _icon(HIcons.tab, l10n.tabs, a.tabs, size: 52),
              _icon(HIcons.bookmarks, l10n.library, a.library, size: 52),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _icon(
                  HIcons.menuLines,
                  l10n.menu,
                  a.menu,
                  size: 52,
                  key: a.menuKey,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Layout "karte" (`P:228`–`P:246`): a grouped card, the address row 56
/// with two lines above the toolbar 56 with a `primary` new-tab pill; one
/// shadow for both.
BarParts cardBar(
  BuildContext context,
  PageState page,
  BarActions a,
  String engine,
) {
  final l10n = AppLocalizations.of(context);
  final scheme = Theme.of(context).colorScheme;
  final glass = HorizontColors.of(context).glass;
  final addr = _Address(context, page, a);
  return BarParts(
    bottom: Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: HorizontShadows.of(context).floating,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            Squish(
              key: a.addressKey,
              semanticLabel: addr.text.isEmpty ? addr.placeholder : addr.text,
              pressedScale: 0.97,
              onTap: a.search,
              child: Container(
                height: 56,
                padding: const EdgeInsets.only(left: 20, right: 4),
                decoration: BoxDecoration(
                  color: glass,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                    bottom: Radius.circular(8),
                  ),
                ),
                child: Stack(
                  children: [
                    Row(
                      spacing: 12,
                      children: [
                        SymbolIcon(
                          addr.icon ??
                              (page.secure ? HIcons.lock : HIcons.search),
                          size: 20,
                          color: scheme.primary,
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                addr.text.isEmpty
                                    ? addr.placeholder
                                    : addr.text,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: HorizontType.address
                                    .withWeight(700)
                                    .copyWith(color: scheme.onSurface),
                              ),
                              Text(
                                addr.subtitle(engine),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: HorizontType.label.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _icon(
                          HIcons.refresh,
                          l10n.reload,
                          a.reload,
                          iconSize: 22,
                        ),
                      ],
                    ),
                    Positioned(
                      left: 0,
                      right: 16,
                      bottom: 0,
                      child: ProgressLine(progress: addr.progress),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: glass,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                  bottom: Radius.circular(24),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _icon(HIcons.arrowBack, l10n.back, a.back),
                  _icon(HIcons.arrowForward, l10n.forward, a.forward),
                  Squish(
                    semanticLabel: l10n.newTab,
                    onTap: a.newTab,
                    child: Container(
                      width: 64,
                      height: 44,
                      decoration: BoxDecoration(
                        color: scheme.primary,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      alignment: Alignment.center,
                      child: SymbolIcon(HIcons.add, color: scheme.onPrimary),
                    ),
                  ),
                  _tabsButton(context, a),
                  _icon(HIcons.menu, l10n.menu, a.menu, key: a.menuKey),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Layout "minimal" (`P:249`–`P:257`): an address pill 44 and a menu button
/// 44, bottom 20. Also the shrunk form of every layout while scrolling.
BarParts minimalBar(
  BuildContext context,
  PageState page,
  BarActions a, {
  bool withKeys = true,
  VoidCallback? onTapAddress,
}) {
  final l10n = AppLocalizations.of(context);
  final addr = _Address(context, page, a);
  final glass = HorizontColors.of(context).glass;
  final shadow = HorizontShadows.of(context).button;
  return BarParts(
    bottom: Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 8,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 200, maxWidth: 260),
            child: DecoratedBox(
              key: withKeys ? a.addressKey : null,
              decoration: BoxDecoration(
                color: glass,
                borderRadius: BorderRadius.circular(22),
                boxShadow: shadow,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: AddressPill(
                  height: 44,
                  small: true,
                  text: addr.text,
                  placeholder: addr.placeholder,
                  secure: page.secure,
                  icon: addr.icon,
                  onTap: onTapAddress ?? a.search,
                  progress: addr.progress,
                ),
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: shadow,
            ),
            child: RoundButton(
              key: withKeys ? a.menuKey : null,
              icon: HIcons.menu,
              semanticLabel: l10n.menu,
              size: 44,
              iconSize: 20,
              look: ButtonLook.glass,
              onTap: a.menu,
              onLongPress: a.tabs,
            ),
          ),
        ],
      ),
    ),
  );
}
