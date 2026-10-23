import 'package:flutter/foundation.dart';

/// What the buttons of a bar do. Every layout takes the same actions, so a
/// bar widget never knows about engines or tabs.
@immutable
class BarActions {
  const BarActions({
    required this.back,
    required this.forward,
    required this.reload,
    required this.search,
    required this.menu,
    this.tabs,
  });

  /// Null where the action is not possible (nothing to go back to).
  final VoidCallback? back;
  final VoidCallback? forward;
  final VoidCallback reload;
  final VoidCallback search;
  final VoidCallback menu;

  /// Opens the tab overview. The compact bar has no button for it; until the
  /// menu sheet (milestone 5) lists it, a long press on the menu button does.
  final VoidCallback? tabs;
}
