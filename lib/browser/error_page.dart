import 'package:material_ui/material_ui.dart';

import '../l10n/app_localizations.dart';
import '../theme/type.dart';
import '../ui/buttons.dart';
import '../ui/shapes.dart';
import 'web_engine.dart';

/// What the shell shows over a page that could not be loaded: no network,
/// a refused certificate, HTTPS-only without HTTPS (PLAN 4.2, M11).
class ErrorPage extends StatelessWidget {
  const ErrorPage({
    super.key,
    required this.error,
    required this.onRetry,
    required this.onContinueInsecure,
    required this.onBack,
    this.topPadding = 0,
  });

  final PageError error;
  final VoidCallback onRetry;
  final VoidCallback onContinueInsecure;
  final VoidCallback? onBack;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final host = error.url.host.isEmpty ? error.url.toString() : error.url.host;
    final (icon, title, body, preset) = switch (error.kind) {
      PageErrorKind.offline => (
        HIcons.cloudOff,
        l10n.offlineTitle,
        l10n.offlineBody(host),
        ShapePreset.sunny,
      ),
      PageErrorKind.certificate => (
        HIcons.gppMaybe,
        l10n.certificateTitle,
        l10n.certificateBody(host),
        ShapePreset.hero6,
      ),
      PageErrorKind.insecure => (
        HIcons.lockOpen,
        l10n.insecureTitle,
        l10n.insecureBody(host),
        ShapePreset.hero6,
      ),
      PageErrorKind.failed => (
        HIcons.errorIcon,
        l10n.failedTitle,
        l10n.failedBody(host),
        ShapePreset.flower,
      ),
    };
    final warn =
        error.kind == PageErrorKind.certificate ||
        error.kind == PageErrorKind.insecure;
    return ColoredBox(
      color: scheme.surfaceContainer,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(28, 72 + topPadding, 28, 160),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              MorphingShapeBadge(
                preset: preset,
                size: 116,
                color: warn ? scheme.errorContainer : scheme.tertiaryContainer,
                child: SymbolIcon(
                  icon,
                  size: 48,
                  color: warn
                      ? scheme.onErrorContainer
                      : scheme.onTertiaryContainer,
                ),
              ),
              Text(
                title,
                style: HorizontType.display.copyWith(color: scheme.onSurface),
              ),
              Text(
                body,
                style: HorizontType.subtitle.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (error.kind != PageErrorKind.insecure)
                    PillButton(
                      icon: HIcons.refresh,
                      label: l10n.tryAgain,
                      height: 52,
                      look: ButtonLook.primary,
                      onTap: onRetry,
                    ),
                  if (onBack != null)
                    PillButton(
                      icon: HIcons.arrowBack,
                      label: l10n.back,
                      height: 52,
                      look: error.kind == PageErrorKind.insecure
                          ? ButtonLook.primary
                          : ButtonLook.highest,
                      onTap: onBack,
                    ),
                  if (error.kind == PageErrorKind.insecure)
                    PillButton(
                      label: l10n.continueInsecure,
                      height: 52,
                      look: ButtonLook.errorContainer,
                      onTap: onContinueInsecure,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
