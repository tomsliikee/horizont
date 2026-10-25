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
  const BarParts({
    required this.bottom,
    this.bottomPadding = EdgeInsets.zero,
    this.bottomRadius = 28,
    this.top,
    this.topReserve = 0,
  });

  /// What floats at the bottom, without its distance from the edges.
  final Widget bottom;
  final EdgeInsets bottomPadding;

  /// The corner radius of the bottom part's outline, which the one surface
  /// of the shrinking bar starts from (PLAN N5).
  final double bottomRadius;
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

/// Home in place of back (PLAN N2): the start page in this tab; going back
/// is the system gesture. Dimmed on the start page itself.
VoidCallback? _home(PageState page, BarActions a) =>
    page.url == null ? null : a.home;

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

/// Layout "kompakt" (`P:159`–`P:172`): glass home button, a glass pill with
/// reader, address and reload, glass menu button. Bottom 28, sides 16.
BarParts compactBar(BuildContext context, PageState page, BarActions a) {
  final l10n = AppLocalizations.of(context);
  final addr = _Address(context, page, a);
  return BarParts(
    bottomPadding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
    bottom: Row(
      spacing: 8,
      children: [
        _dim(
          _home(page, a),
          RoundButton(
            icon: HIcons.home,
            semanticLabel: l10n.home,
            size: 56,
            onTap: _home(page, a),
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
                      onLongPress: a.copyAddress,
                      progress: addr.progress,
                    ),
                  ),
                  if (page.url == null)
                    const SizedBox(width: 12)
                  else
                    _icon(HIcons.refresh, l10n.reload, a.reload, iconSize: 22),
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
  );
}

/// Layout "zweireihig" (`P:175`–`P:189`): the address pill 52 above a
/// toolbar 64 with back, forward, share, library and tabs. Bottom 24.
BarParts twoRowBar(BuildContext context, PageState page, BarActions a) {
  final l10n = AppLocalizations.of(context);
  final addr = _Address(context, page, a);
  return BarParts(
    bottomPadding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
    bottomRadius: 32,
    bottom: Column(
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
              onLongPress: a.copyAddress,
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
                  child: _icon(HIcons.home, l10n.home, _home(page, a)),
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
        child: FloatingSurface(
          key: a.addressKey,
          borderRadius: BorderRadius.circular(22),
          shadows: HorizontShadows.of(context).button,
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
              onLongPress: a.copyAddress,
              progress: addr.progress,
            ),
          ),
        ),
      ),
    ),
    bottomPadding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
    bottomRadius: 32,
    bottom: Row(
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
                  _icon(HIcons.home, l10n.home, _home(page, a)),
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
                  onLongPress: a.copyAddress,
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
    bottomPadding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
    bottomRadius: 32,
    bottom: FloatingSurface(
      borderRadius: BorderRadius.circular(32),
      child: SizedBox(
        height: 64,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: PillButton(
                icon: HIcons.home,
                label: l10n.startNav,
                look: ButtonLook.primary,
                onTap: onPage ? a.home : a.search,
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
  final colors = HorizontColors.of(context);
  final addr = _Address(context, page, a);
  return BarParts(
    bottomPadding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
    bottomRadius: 24,
    bottom: DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        // One shadow for both pieces; none under translucent glass.
        boxShadow: colors.translucentGlass
            ? null
            : HorizontShadows.of(context).floating,
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
            onLongPress: a.copyAddress,
            child: FloatingSurface(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
                bottom: Radius.circular(8),
              ),
              shadows: const [],
              child: Container(
                height: 56,
                padding: const EdgeInsets.only(left: 20, right: 4),

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
          ),
          FloatingSurface(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(8),
              bottom: Radius.circular(24),
            ),
            shadows: const [],
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 8),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _icon(HIcons.home, l10n.home, _home(page, a)),
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
          ),
        ],
      ),
    ),
  );
}

/// Layout "minimal" (`P:249`–`P:257`): an address pill 44 and a menu button
/// 44, bottom 20.
///
/// [shrunk] is the form every other layout shrinks to while the page is read
/// (PLAN N5): only the address, thinner (34), centred over the gesture bar;
/// a tap brings the full bar back with its menu. Then it is [bare] and
/// [surfaceKey] tells where its address surface lies.
BarParts minimalBar(
  BuildContext context,
  PageState page,
  BarActions a, {
  bool withKeys = true,
  VoidCallback? onTapAddress,
  Key? surfaceKey,
  bool bare = false,
  bool shrunk = false,
}) {
  final l10n = AppLocalizations.of(context);
  final addr = _Address(context, page, a);
  final shadow = HorizontShadows.of(context).button;
  final height = shrunk ? 34.0 : 44.0;
  final address = ConstrainedBox(
    key: surfaceKey,
    constraints: shrunk
        ? const BoxConstraints(minWidth: 168, maxWidth: 220)
        : const BoxConstraints(minWidth: 200, maxWidth: 260),
    child: _MaybeSurface(
      key: withKeys ? a.addressKey : null,
      // Bare while it is the shrinking bar's surface that is drawn.
      bare: bare,
      radius: height / 2,
      shadows: shadow,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: shrunk ? 14 : 18),
        child: AddressPill(
          height: height,
          small: true,
          text: addr.text,
          placeholder: addr.placeholder,
          secure: page.secure,
          icon: addr.icon,
          onTap: onTapAddress ?? a.search,
          onLongPress: a.copyAddress,
          progress: addr.progress,
        ),
      ),
    ),
  );
  if (shrunk) {
    return BarParts(
      bottomPadding: const EdgeInsets.only(bottom: 34),
      bottomRadius: height / 2,
      bottom: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [address],
      ),
    );
  }
  return BarParts(
    bottomPadding: const EdgeInsets.only(bottom: 20),
    bottomRadius: 22,
    bottom: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 8,
      children: [
        address,
        DecoratedBox(
          decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: shadow),
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
  );
}

/// The pill's glass, or nothing where the shrinking bar draws it.
class _MaybeSurface extends StatelessWidget {
  const _MaybeSurface({
    super.key,
    required this.bare,
    required this.radius,
    required this.shadows,
    required this.child,
  });

  final bool bare;
  final double radius;
  final List<BoxShadow> shadows;
  final Widget child;

  @override
  Widget build(BuildContext context) => bare
      ? child
      : FloatingSurface(
          borderRadius: BorderRadius.circular(radius),
          shadows: shadows,
          child: child,
        );
}
