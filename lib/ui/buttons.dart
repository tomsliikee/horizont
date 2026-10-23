import 'package:material_ui/material_ui.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../theme/extensions.dart';
import '../theme/type.dart';
import 'squish.dart';

/// How a [RoundButton] or [PillButton] is filled.
enum ButtonLook {
  /// Floating over content: glass with a shadow.
  glass,

  /// `surfaceContainerHighest`, no shadow.
  highest,

  /// No fill.
  plain,

  /// The one main action.
  primary,

  errorContainer,
  error,
}

({Color fill, Color ink, bool shadow}) _colours(
  BuildContext context,
  ButtonLook look,
) {
  final scheme = Theme.of(context).colorScheme;
  final extra = HorizontColors.of(context);
  return switch (look) {
    ButtonLook.glass => (
      fill: extra.glass,
      ink: scheme.onSurface,
      shadow: true,
    ),
    ButtonLook.highest => (
      fill: scheme.surfaceContainerHighest,
      ink: scheme.onSurfaceVariant,
      shadow: false,
    ),
    ButtonLook.plain => (
      fill: const Color(0x00000000),
      ink: scheme.onSurfaceVariant,
      shadow: false,
    ),
    ButtonLook.primary => (
      fill: scheme.primary,
      ink: scheme.onPrimary,
      shadow: false,
    ),
    ButtonLook.errorContainer => (
      fill: scheme.errorContainer,
      ink: scheme.onErrorContainer,
      shadow: false,
    ),
    ButtonLook.error => (
      fill: scheme.error,
      ink: scheme.onError,
      shadow: false,
    ),
  };
}

/// A material symbol with the design system's weights.
class SymbolIcon extends StatelessWidget {
  const SymbolIcon(
    this.icon, {
    super.key,
    this.size = 24,
    this.filled = false,
    this.color,
  });

  final IconData icon;
  final double size;
  final bool filled;
  final Color? color;

  @override
  Widget build(BuildContext context) => Icon(
    icon,
    size: size,
    color: color,
    fill: filled ? 1 : 0,
    weight: 400,
    opticalSize: size.clamp(20, 48).toDouble(),
  );
}

/// A circle of [size] 44, 48 or 56 with an icon.
class RoundButton extends StatelessWidget {
  const RoundButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    this.onTap,
    this.onLongPress,
    this.size = 48,
    this.iconSize = 24,
    this.look = ButtonLook.glass,
    this.filled = false,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double size;
  final double iconSize;
  final ButtonLook look;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final c = _colours(context, look);
    return Squish(
      onTap: onTap,
      onLongPress: onLongPress,
      semanticLabel: semanticLabel,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: c.fill,
          shape: BoxShape.circle,
          boxShadow: c.shadow ? HorizontShadows.of(context).button : null,
        ),
        alignment: Alignment.center,
        child: SymbolIcon(icon, size: iconSize, filled: filled, color: c.ink),
      ),
    );
  }
}

/// A pill with an icon and/or label, 44 to 56 high.
class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    this.icon,
    this.label,
    this.onTap,
    this.height = 48,
    this.look = ButtonLook.highest,
    this.semanticLabel,
  }) : assert(icon != null || label != null);

  final IconData? icon;
  final String? label;
  final VoidCallback? onTap;
  final double height;
  final ButtonLook look;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = _colours(context, look);
    return Squish(
      onTap: onTap,
      semanticLabel: semanticLabel ?? label,
      child: Container(
        height: height,
        padding: EdgeInsets.symmetric(horizontal: label == null ? 14 : 20),
        decoration: BoxDecoration(
          color: c.fill,
          borderRadius: BorderRadius.circular(height / 2),
          boxShadow: c.shadow ? HorizontShadows.of(context).button : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) SymbolIcon(icon!, size: 20, color: c.ink),
            if (icon != null && label != null) const SizedBox(width: 8),
            if (label != null)
              Text(
                label!,
                style: HorizontType.bodyMedium.copyWith(
                  color: c.ink,
                  fontSize: 15,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Every icon the prototype uses (64), checked in `test/ui/icons_test.dart`.
abstract final class HIcons {
  static const accessibilityNew = Symbols.accessibility_new_rounded;
  static const add = Symbols.add_rounded;
  static const addToHomeScreen = Symbols.add_to_home_screen_rounded;
  static const arrowBack = Symbols.arrow_back_rounded;
  static const arrowForward = Symbols.arrow_forward_rounded;
  static const arrowOutward = Symbols.arrow_outward_rounded;
  static const autoDelete = Symbols.auto_delete_rounded;
  static const block = Symbols.block_rounded;
  static const book2 = Symbols.book_2_rounded;
  static const bookmark = Symbols.bookmark_rounded;
  static const bookmarkAdd = Symbols.bookmark_add_rounded;
  static const bookmarks = Symbols.bookmarks_rounded;
  static const brightnessAuto = Symbols.brightness_auto_rounded;
  static const cancel = Symbols.cancel_rounded;
  static const checkCircle = Symbols.check_circle_rounded;
  static const chevronRight = Symbols.chevron_right_rounded;
  static const chromeReaderMode = Symbols.chrome_reader_mode_rounded;
  static const close = Symbols.close_rounded;
  static const darkMode = Symbols.dark_mode_rounded;
  static const deleteForever = Symbols.delete_forever_rounded;
  static const desktopWindows = Symbols.desktop_windows_rounded;
  static const download = Symbols.download_rounded;
  static const eyeglasses = Symbols.eyeglasses_rounded;
  static const findInPage = Symbols.find_in_page_rounded;
  static const fingerprint = Symbols.fingerprint_rounded;
  static const folderOpen = Symbols.folder_open_rounded;
  static const formatSize = Symbols.format_size_rounded;
  static const gppMaybe = Symbols.gpp_maybe_rounded;
  static const hiking = Symbols.hiking_rounded;
  static const history = Symbols.history_rounded;
  static const home = Symbols.home_rounded;
  static const image = Symbols.image_rounded;
  static const info = Symbols.info_rounded;
  static const iosShare = Symbols.ios_share_rounded;
  static const language = Symbols.language_rounded;
  static const lightMode = Symbols.light_mode_rounded;
  static const lock = Symbols.lock_rounded;
  static const map = Symbols.map_rounded;
  static const menuLines = Symbols.menu_rounded;
  static const mic = Symbols.mic_rounded;
  static const menu = Symbols.more_horiz_rounded;
  static const moreVert = Symbols.more_vert_rounded;
  static const newspaper = Symbols.newspaper_rounded;
  static const northWest = Symbols.north_west_rounded;
  static const palette = Symbols.palette_rounded;
  static const partlyCloudyDay = Symbols.partly_cloudy_day_rounded;
  static const password = Symbols.password_rounded;
  static const pause = Symbols.pause_rounded;
  static const pictureAsPdf = Symbols.picture_as_pdf_rounded;
  static const refresh = Symbols.refresh_rounded;
  static const remove = Symbols.remove_rounded;
  static const restaurant = Symbols.restaurant_rounded;
  static const school = Symbols.school_rounded;
  static const search = Symbols.search_rounded;
  static const settings = Symbols.settings_rounded;
  static const shield = Symbols.shield_rounded;
  static const signalCellular4Bar = Symbols.signal_cellular_4_bar_rounded;
  static const star = Symbols.star_rounded;
  static const tab = Symbols.tab_rounded;
  static const translate = Symbols.translate_rounded;
  static const tune = Symbols.tune_rounded;
  static const visibilityOff = Symbols.visibility_off_rounded;
  static const vpnLock = Symbols.vpn_lock_rounded;
  static const wifi = Symbols.wifi_rounded;

  static const all = <IconData>[
    accessibilityNew,
    add,
    addToHomeScreen,
    arrowBack,
    arrowForward,
    arrowOutward,
    autoDelete,
    block,
    book2,
    bookmark,
    bookmarkAdd,
    bookmarks,
    brightnessAuto,
    cancel,
    checkCircle,
    chevronRight,
    chromeReaderMode,
    close,
    darkMode,
    deleteForever,
    desktopWindows,
    download,
    eyeglasses,
    findInPage,
    fingerprint,
    folderOpen,
    formatSize,
    gppMaybe,
    hiking,
    history,
    home,
    image,
    info,
    iosShare,
    language,
    lightMode,
    lock,
    map,
    menuLines,
    mic,
    menu,
    moreVert,
    newspaper,
    northWest,
    palette,
    partlyCloudyDay,
    password,
    pause,
    pictureAsPdf,
    refresh,
    remove,
    restaurant,
    school,
    search,
    settings,
    shield,
    signalCellular4Bar,
    star,
    tab,
    translate,
    tune,
    visibilityOff,
    vpnLock,
    wifi,
  ];
}
