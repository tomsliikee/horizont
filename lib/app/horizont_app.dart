import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/app_localizations.dart';
import '../platform/horizont_webkit.dart';
import '../theme/horizont_theme.dart';
import '../ui/haptics.dart';
import 'browser_shell.dart';
import 'providers.dart';
import 'system_ui.dart';

class HorizontApp extends ConsumerStatefulWidget {
  const HorizontApp({super.key, required this.home});

  final Widget home;

  @override
  ConsumerState<HorizontApp> createState() => _HorizontAppState();
}

class _HorizontAppState extends ConsumerState<HorizontApp> {
  final _themes = ThemeCache();

  @override
  void initState() {
    super.initState();
    // Pages see the app's light or dark choice (R6).
    ref.listenManual(
      settingsProvider.select((s) => s.themeMode),
      (_, mode) => unawaited(HorizontWebKit.setNightMode(mode.name)),
      fireImmediately: true,
    );
    ref.listenManual(
      settingsProvider.select((s) => s.haptics),
      (_, level) => Haptics.level = level,
      fireImmediately: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final palette = ref.watch(systemPaletteProvider).value;
    // Material You is the default where the system has a palette (D3); the
    // wallpaper choice falls back to blue where it has none.
    final colourway = settings.colourway;
    return MaterialApp(
      title: 'Horizont',
      debugShowCheckedModeBanner: false,
      theme: _themes.get(
        colourway,
        Brightness.light,
        palette: palette,
        translucentBars: settings.translucentBars,
      ),
      darkTheme: _themes.get(
        colourway,
        Brightness.dark,
        palette: palette,
        translucentBars: settings.translucentBars,
      ),
      themeMode: settings.themeMode,
      // A theme change animates; the extensions lerp too (PLAN 2.6).
      themeAnimationDuration: const Duration(milliseconds: 350),
      themeAnimationCurve: Curves.easeOutCubic,
      localizationsDelegates: [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => PrivateLockLayer(child: child!),
      home: SystemUiRegion(child: widget.home),
    );
  }
}
