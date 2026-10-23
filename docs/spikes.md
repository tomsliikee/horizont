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

