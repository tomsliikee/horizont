# Spikes

> Written 2026-10-23 during M2. Each answer is marked *tested* (with how), *built* or *planned*.

## Bridge: native `WebView` by identifier

- *Tested* on the Pixel 10 Pro (profile build, `adb logcat -s flutter`): `WebViewFlutterAndroidExternalApi.getWebView(binding, id)` finds the view (`found: true`) with the identifier from `AndroidWebViewController.webViewIdentifier`.
- *Tested* (same log): `WebViewFeature` reports supported: `MULTI_PROFILE`, `DOCUMENT_START_SCRIPT`, `SAFE_BROWSING_ENABLE`, `ALGORITHMIC_DARKENING`, `WEB_AUTHENTICATION`.
- *Tested* (same log): the plugin's `WebViewClient` is `io.flutter.plugins.webviewflutter.WebViewClientProxyApi$WebViewClientImpl`. Wrapping it for `shouldInterceptRequest` (R4) is still open.

## Results on the Pixel 10 Pro (2026-10-23, profile build, adb input)

| Question | Result |
| :--- | :--- |
| Real browsing (URL, search, links, reload) | *Tested:* `example.com`, a Google search ("wetter wien") and Wikipedia load; page sits below the status bar, bar floats over it, domain and lock show. Back: `goBack` runs and returns from Wikipedia to `example.com` (log). Google's results page adds its own history entries, so several taps on back there show the same page. |
| TLHC (default) scroll | *Tested:* 8 swipes up and 8 down on the Bergzeit page, `FRAME_STATS`: 940 frames, build+raster p50 4.1 ms, p90 6.0, p99 8.3, max 16.9; 9 frames over 8.3 ms, 1 over 16.6. Within the 7.1 budget (99 % under 8.3 ms) only just. |
| Hybrid Composition scroll | *Tested* the same way, but not comparable: Flutter drew only 94 frames (the page scrolls in the platform view), p99 18.8 ms, 2 over 16.6. Smoothness of the page itself was not measured. Decision for now: stay with TLHC. |
| Typing into a page field | *Tested* (TLHC, Gboard): text arrives. **Finding:** with the keyboard up the bar still floats above it and covers the field's surroundings; the field sat half behind the keyboard. The bar must hide while the keyboard is up (PLAN 5.7 item 9) and the page must resize. `ime` was not added to the ignored insets. |
| Blur over the page | *Planned*: not tried; `FloatingSurface(blur: true)` exists. |
| Video, TalkBack, Hybrid typing | *Planned*: not tried. |
| `setProfile` before the first load | *Tested:* `WebViewCompat.setProfile(view, "spike")` right after creation succeeds and `getProfile` reports it. Isolation of cookies between profiles is **not** tested (needs a login in two tabs; M7). |
| Own download listener next to the plugin's | *Tested:* after `view.setDownloadListener(...)`, opening a PDF URL calls it with URL, MIME type (`application/pdf`) and length (13264). It replaces the plugin's listener, which only forwarded the URL. |
| Wrapping `shouldInterceptRequest` | *Tested:* a `WebViewClient` that delegates `shouldInterceptRequest`, `shouldOverrideUrlLoading`, `onPageStarted`, `onPageFinished` and `doUpdateVisitedHistory` to the plugin's client sees every request (logged: `wikipedia.org`, favicon) and navigation state still reached Dart. Risk: the plugin replaces the client if a new `NavigationDelegate` is set; the wrapper has to be installed after it, and the other client callbacks must be forwarded too. D5 (a fork) is not needed yet. |
| Status bar taps reach the app | *Tested:* a tap at y = 70 px (inside the status bar) produced no pointer event in Flutter, taps on the bar and the page did. So R5 holds: scroll to top uses the soft edge (5.6). |

The spike code (a `spike` call in `HorizontWebKitPlugin`) was removed afterwards; the calls above are the ones M3, M6, M7 and M8 will implement.

## M3: scroll smoothness, Texture Layer vs Hybrid Composition (2026-10-23)

Wikipedia (Wien), one 2 s swipe, `screenrecord` frame timestamps, three runs each, Pixel 10 Pro, profile build. Frame gaps, 6–11 ms counts as 120 Hz:

| | 6–11 ms | 14–20 ms | > 20 ms |
|---|---|---|---|
| Texture Layer (before) | 187 / 151 / 223 | 27 / 121 / 94 | 6 / 25 / 14 |
| Hybrid Composition | 310 / 333 / 267 | 6 / 6 / 29 | 2 / 4 / 2 |

Texture Layer mixed long stretches at 60 Hz into the scroll, which looks like judder although the Flutter side reported no jank (`gfxinfo`: 0 janky, p99 5 ms). Switching the script off changed nothing, so it is the composition path. Hybrid is now the default (`HYBRID=false` switches back). *Tested after the switch:* bars and the tint edge still float over the page, tap on the edge scrolls to the top. Not checked with Hybrid: keyboard, blur over the page (not used), TalkBack.

## M4: thumbnails, many tabs (2026-10-23)

- *Tested* on the Pixel 10 Pro (profile build): `WebView.draw` into a scaled bitmap (WebP, 400 px wide) gives a correct picture in Hybrid Composition; the overview shows real page pictures.
- *Tested:* 20 Wikipedia tabs, pool of 3. `dumpsys meminfo` total PSS 544 MB with one tab, 650 to 680 MB with twenty. Not measured: after closing them, and after minutes in the background.
- *Tested:* scrolling the overview of 20 cards, `FRAME_STATS`: build 0.3 to 1.1 ms, raster 2.2 to 5.8 ms, one frame at 9.4 ms in about 100.
- *Tested:* force-stop and start: 20 tabs, their pictures and the tab in front are back.
- *Finding:* the page script's scroll messages carry the position only when "scrolled" or "at the end" changes, so they cannot be used to restore a position. `readScrollY` asks the page when a tab is left, evicted or the app pauses.


## N4: performance, first pass (2026-10-25, emulator Pixel_10, x86_64 profile build)

The Pixel 10 Pro was not connected, so these are emulator numbers: good for before/after on the same machine, not for the budgets of PLAN 7.1.

| **Area** | **Before** | **After** | **How** |
| :--- | :--- | :--- | :--- |
| Cold start, own page visible (tab with a page in front) | start page at 0.85 s, the page replaces it at 2.3 s | the page (its picture) at 0.8 s, live without a jump at 2.1 s | `screenrecord` at 30 fps, brightness of the title area per frame |
| Flutter first frame built (`--trace-startup`, 3 runs) | 318 / 325 / 367 ms | 147 / 204 / 312 ms | `timeToFirstFrameMicros` |
| Flutter first frame rasterised (3 runs) | 362 / 364 / 411 ms | 359 / 407 / 443 ms | `timeToFirstFrameRasterizedMicros`; the first frame now also creates the web view of the real tab |
| Start page rebuilds per 10 tab/page events while it shows | 10 | 0 | widget test with `debugOnRebuildDirtyWidget` |

- *Tested:* the snapshot of the tab in front (`SettingsStore.activeSnapshot`) lets the first frame show that tab instead of a throwaway empty tab; the database fills in the rest. Tests in `tabs_notifier_test.dart`.
- *Tested:* the shell watches only the tab fields it shows (`_ShellTabs`) and keeps one start page instance.
- *Tested:* `springTo` sets the exact target at rest; before, opacities stayed at 0.9999 and kept a layer alive.
- *Built, emulator only:* the picture of a tab shows until its page reports, also on a switch to a cold tab; the picture is taken when the app pauses.
- Not measured: scroll frame times, tab switch and overview with 20 tabs, memory after closing tabs. They need the Pixel (PLAN 7.4).

## N5: smoothness on 120 Hz, the bar morph, the glass (2026-10-25, emulator Pixel_10 at 120 Hz, x86_64 profile build)

Thomas felt the release build on the Pixel 10 Pro stutter when opening settings and while scrolling. Measured on the emulator only (at his request), with the display set to 120 Hz (`hw.lcd.vsync = 120` in the AVD, `peak_refresh_rate` and `min_refresh_rate` 120); at 60 Hz nothing showed. Impeller ran on OpenGL ES. Emulator numbers compare before and after; they do not prove the Pixel's budgets.

**Cause found:** Impeller rasterises text anew at every scale. The screen transition scaled the whole incoming screen (92 → 100 %), the start page came in from 96 %, the overview from 106 %, and the bar squeezed itself with its address text into the pill. Each of those frames redrew every glyph.

| **Measurement** | **Before** | **After** | **How** |
| :--- | :--- | :--- | :--- |
| Settings opened and closed 4 times: Flutter frames over 8.3 ms | 114 / 110 (of ~730) | 23 / 19 (of ~810) | `FRAME_STATS` build, raster + build per frame |
| Same, raster p99 | 17.9 / 18.1 ms | 9.9 / 8.9 ms | same |
| Web page, 6 swipes: screen frames late (gap 21–150 ms) | 42 / 22 | 13 / 15 / 20 | `screenrecord` frame gaps |
| Opening and closing settings: screen frames late | 33 / 12 | 10 / 6 / 11 | same |
| Reference: system Settings app scrolling | 6 / 9 late | | same |

Experiments that changed nothing measurable and were dropped: no opacity in the transition, no rounded clip, no stagger fade, taking the web view offstage under a covering screen, no bars and no status bar tint while scrolling (the web view's own drawing is the bulk there: `gfxinfo` 7–8 % janky with or without the bars).

- *Tested (emulator):* **Hybrid Composition++** (`initHybridAndroidView`, `EnableHcpp` in the manifest) needs Vulkan; with Vulkan forced on the emulator it rendered correctly but scrolled no better than Hybrid Composition. Not adopted; worth a measurement on the Pixel if scrolling stays rough there.
- *Tested (emulator):* **native blur under the bars** fails: a `WebView` drawn a second time into a `RenderNode` (for `RenderEffect.createBlurEffect`) draws its page stretched and from the wrong place; its draw functor assumes its own node. A software capture per frame is far too slow. So with "Durchscheinend" the bars blur only over the app's own screens; over a web page they are translucent without blur (D31).
- *Tested:* the bar morph: one glass surface goes from the bar's outline to the pill's (`bar_morph_test.dart`, all five layouts), screen recording frame by frame.
- Not measured: the Pixel 10 Pro itself.
