import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// What the buttons of a bar do and what they show. Every layout takes the
/// same actions, so a bar widget never knows about engines or tabs.
@immutable
class BarActions {
  const BarActions({
    required this.back,
    required this.forward,
    required this.reload,
    required this.search,
    required this.menu,
    required this.tabs,
    required this.library,
    required this.share,
    required this.newTab,
    required this.home,
    required this.reader,
    this.tabCount = 1,
    this.readerOn = false,
    this.privateMode = false,
    this.addressKey,
    this.menuKey,
  });

  /// Null where the action is not possible (nothing to go back to).
  final VoidCallback? back;
  final VoidCallback? forward;
  final VoidCallback? reload;
  final VoidCallback search;
  final VoidCallback menu;
  final VoidCallback tabs;
  final VoidCallback library;
  final VoidCallback? share;
  final VoidCallback newTab;

  /// The start page of the tab ("Start" in the top layout).
  final VoidCallback home;

  /// Toggles the reader view; null where the page has none.
  final VoidCallback? reader;
  final int tabCount;
  final bool readerOn;
  final bool privateMode;

  /// Where the search grows from and the menu grows out of (PLAN 6.2).
  final GlobalKey? addressKey;
  final GlobalKey? menuKey;

  /// The same actions for a second bar on screen (a layout leaving), which
  /// must not carry the keys of the first.
  BarActions withoutKeys() => BarActions(
    back: back,
    forward: forward,
    reload: reload,
    search: search,
    menu: menu,
    tabs: tabs,
    library: library,
    share: share,
    newTab: newTab,
    home: home,
    reader: reader,
    tabCount: tabCount,
    readerOn: readerOn,
    privateMode: privateMode,
  );
}
