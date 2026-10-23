import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/app_localizations.dart';
import '../theme/horizont_theme.dart';
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
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final palette = ref.watch(systemPaletteProvider).value;
    // Material You is the default where the system has a palette (D3); the
    // wallpaper choice falls back to blue where it has none.
    final colourway = settings.colourway;
    return MaterialApp(
      title: 'Horizont',
      debugShowCheckedModeBanner: false,
      theme: _themes.get(colourway, Brightness.light, palette: palette),
      darkTheme: _themes.get(colourway, Brightness.dark, palette: palette),
      themeMode: settings.themeMode,
      localizationsDelegates: [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: SystemUiRegion(child: widget.home),
    );
  }
}
