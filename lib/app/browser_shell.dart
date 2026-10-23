import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../browser/address.dart';
import '../browser/bars/bar_actions.dart';
import '../browser/bars/compact_bar.dart';
import '../browser/browser_providers.dart';
import '../browser/status_bar/status_bar_look.dart';
import '../browser/status_bar/status_bar_provider.dart';
import '../browser/status_bar/status_bar_tint.dart';
import '../browser/tabs/tabs_notifier.dart';
import '../features/tabs/tabs_page.dart';
import '../features/start/start_page.dart';
import '../l10n/app_localizations.dart';
import 'address_prompt.dart';
import 'providers.dart';
import 'system_ui.dart';

/// The root of the browser: the page at the bottom of a `Stack`, the start
/// page over it while the tab is empty, and the bar floating above both. The
/// page starts below the status bar (PLAN 5.3); the bar floats over its
/// lower edge.
class BrowserShell extends ConsumerStatefulWidget {
  const BrowserShell({super.key});

  @override
  ConsumerState<BrowserShell> createState() => _BrowserShellState();
}

class _BrowserShellState extends ConsumerState<BrowserShell> {
  StreamSubscription<Uri>? _blocked;
  bool _keyboardUp = false;

  @override
  void initState() {
    super.initState();
    _blocked = ref.read(webEngineProvider).blockedLinks.listen((_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.linkNeedsOtherApp)));
    });
  }

  @override
  void dispose() {
    unawaited(_blocked?.cancel());
    super.dispose();
  }

  Future<void> _search() async {
    final engine = ref.read(webEngineProvider);
    final input = await showAddressPrompt(
      context,
      initial: ref.read(pageStateProvider).url?.toString() ?? '',
    );
    if (input == null || !mounted) return;
    // Local test pages for the spikes; not reachable in a release build.
    if (!kReleaseMode && input.trim() == 'test:bergzeit') {
      await engine.loadAsset('assets/test_pages/bergzeit.html');
      return;
    }
    final uri = resolveAddress(input, ref.read(searchEngineProvider));
    if (uri != null) await engine.load(uri);
  }

  @override
  Widget build(BuildContext context) {
    final engine = ref.watch(webEngineProvider);
    final page = ref.watch(pageStateProvider);
    final scheme = Theme.of(context).colorScheme;
    final top = MediaQuery.viewPaddingOf(context).top;
    final status = ref.watch(statusBarProvider);
    final tint = ref.watch(settingsProvider.select((s) => s.tintFromPage));
    final look = statusBarLook(
      onPage: page.url != null,
      tint: tint,
      pageColor: status.pageColor,
      scrolled: status.scrolled,
      surface: scheme.surfaceContainer,
    );
    // The bar steps aside for the keyboard; the Scaffold shrinks the page to
    // the space above it, so a focused page field stays in view.
    final keyboardUp = MediaQuery.viewInsetsOf(context).bottom > 0;
    if (keyboardUp != _keyboardUp) {
      _keyboardUp = keyboardUp;
      // Once the page has resized to the space above the keyboard, bring the
      // field being typed in back into the middle of it.
      if (keyboardUp) {
        Timer(const Duration(milliseconds: 350), () {
          if (mounted) unawaited(engine.revealFocusedField());
        });
      }
    }

    final actions = BarActions(
      back: page.canGoBack ? engine.goBack : null,
      forward: page.canGoForward ? engine.goForward : null,
      reload: engine.reload,
      search: _search,
      menu: () {}, // The menu sheet comes with milestone 5.
      tabs: () => unawaited(showTabsPage(context, ref)),
    );

    // Back: the page's history first, then back to the tab this one was opened
    // from (closing it), then the start page, then the app.
    final tabs = ref.watch(tabsProvider);
    final openerId = tabs.active.openerId;
    final hasOpener = openerId != null && tabs.byId(openerId) != null;
    return PopScope(
      canPop: page.url == null && !page.canGoBack && !hasOpener,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (page.canGoBack) {
          unawaited(engine.goBack());
        } else if (hasOpener) {
          final notifier = ref.read(tabsProvider.notifier);
          notifier.activate(openerId);
          notifier.close(tabs.activeId);
        } else {
          unawaited(engine.goToStart());
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: systemUiStyle(
          contentBrightness: statusBarContentBrightness(look),
          navigationBrightness: scheme.brightness,
        ),
        child: Scaffold(
          backgroundColor: scheme.surfaceContainer,
          body: Stack(
            children: [
              Positioned.fill(
                top: top,
                child: KeyedSubtree(
                  key: ValueKey(tabs.activeId),
                  child: engine.buildView(),
                ),
              ),
              if (page.url == null) const Positioned.fill(child: StartPage()),
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: StatusBarTint(
                  look: look,
                  height: top,
                  onTapEdge: page.url == null
                      ? null
                      : () {
                          HapticFeedback.selectionClick();
                          unawaited(engine.scrollToTop());
                        },
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: IgnorePointer(
                  ignoring: keyboardUp,
                  child: AnimatedSlide(
                    offset: keyboardUp ? const Offset(0, 1.5) : Offset.zero,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    child: CompactBar(page: page, actions: actions),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
