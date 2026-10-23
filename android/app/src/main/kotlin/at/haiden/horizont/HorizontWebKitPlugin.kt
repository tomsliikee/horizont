package at.haiden.horizont

import android.app.Activity
import android.app.UiModeManager
import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.content.pm.ShortcutInfo
import android.content.pm.ShortcutManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.Typeface
import android.graphics.drawable.Icon
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.webkit.CookieManager
import android.webkit.WebView
import androidx.webkit.ProfileStore
import androidx.webkit.WebSettingsCompat
import androidx.webkit.WebViewCompat
import androidx.webkit.WebViewFeature
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugins.webviewflutter.WebViewFlutterAndroidExternalApi
import java.util.concurrent.Executors

/**
 * What `webview_flutter` does not expose, reached through the native `WebView`
 * that the plugin keeps under an identifier (PLAN 4.5): profiles, the page
 * script at document start, captures, find in page, downloads, request
 * blocking, new windows, and the intents a browser needs (share, open
 * elsewhere, pin to the home screen, links from other apps).
 */
class HorizontWebKitPlugin :
    FlutterPlugin,
    MethodChannel.MethodCallHandler,
    ActivityAware,
    PluginRegistry.NewIntentListener,
    PluginRegistry.RequestPermissionsResultListener {
    private var binding: FlutterPlugin.FlutterPluginBinding? = null
    private var channel: MethodChannel? = null
    private var activity: ActivityPluginBinding? = null
    private val main = Handler(Looper.getMainLooper())
    private val background = Executors.newSingleThreadExecutor()
    private val clients = mutableMapOf<Long, HorizontWebViewClient>()
    private var pendingPermissions: MethodChannel.Result? = null
    private var initialUrl: String? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        this.binding = binding
        channel = MethodChannel(binding.binaryMessenger, "at.haiden.horizont/webkit").also {
            it.setMethodCallHandler(this)
        }
        val path = binding.flutterAssets.getAssetFilePathByName("assets/blocklist/easyprivacy_domains.txt")
        background.execute { Blocklist.load(binding.applicationContext, path) }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        channel = null
        this.binding = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding
        binding.addOnNewIntentListener(this)
        binding.addRequestPermissionsResultListener(this)
        initialUrl = viewUrl(binding.activity.intent)
    }

    override fun onDetachedFromActivityForConfigChanges() = onDetachedFromActivity()

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) =
        onAttachedToActivity(binding)

    override fun onDetachedFromActivity() {
        activity?.removeOnNewIntentListener(this)
        activity?.removeRequestPermissionsResultListener(this)
        activity = null
    }

    override fun onNewIntent(intent: Intent): Boolean {
        val url = viewUrl(intent) ?: return false
        channel?.invokeMethod("onOpenUrl", mapOf("url" to url))
        return true
    }

    private fun viewUrl(intent: Intent?): String? {
        if (intent?.action != Intent.ACTION_VIEW) return null
        val data = intent.data ?: return null
        return if (data.scheme == "http" || data.scheme == "https") data.toString() else null
    }

    private fun send(method: String, args: Map<String, Any?>) {
        main.post { channel?.invokeMethod(method, args) }
    }

    private fun identifier(call: MethodCall): Long? = call.argument<Number>("identifier")?.toLong()

    private fun webView(call: MethodCall): WebView? {
        val id = identifier(call) ?: return null
        val binding = binding ?: return null
        return WebViewFlutterAndroidExternalApi.getWebView(binding, id)
    }

    private fun supported(feature: String) = WebViewFeature.isFeatureSupported(feature)

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            handle(call, result)
        } catch (e: Exception) {
            result.error("horizont", e.message, null)
        }
    }

    private fun handle(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "probe" -> {
                val view = webView(call)
                result.success(
                    mapOf(
                        "found" to (view != null),
                        "webViewClient" to view?.webViewClient?.javaClass?.name,
                        "features" to mapOf(
                            "MULTI_PROFILE" to supported(WebViewFeature.MULTI_PROFILE),
                            "DOCUMENT_START_SCRIPT" to supported(WebViewFeature.DOCUMENT_START_SCRIPT),
                            "SAFE_BROWSING_ENABLE" to supported(WebViewFeature.SAFE_BROWSING_ENABLE),
                            "ALGORITHMIC_DARKENING" to supported(WebViewFeature.ALGORITHMIC_DARKENING),
                            "WEB_AUTHENTICATION" to supported(WebViewFeature.WEB_AUTHENTICATION),
                        ),
                    ),
                )
            }
            // Everything a new view needs, in order, before its first load:
            // the profile must come first (R3).
            "setup" -> {
                val id = identifier(call)
                val view = webView(call)
                if (id == null || view == null) {
                    result.success(mapOf("found" to false))
                    return
                }
                val profile = call.argument<String>("profile")
                var profileSet = false
                if (profile != null && supported(WebViewFeature.MULTI_PROFILE)) {
                    ProfileStore.getInstance().getOrCreateProfile(profile)
                    WebViewCompat.setProfile(view, profile)
                    profileSet = true
                }
                val script = call.argument<String>("script")
                var scriptAdded = false
                if (script != null && supported(WebViewFeature.DOCUMENT_START_SCRIPT)) {
                    WebViewCompat.addDocumentStartJavaScript(view, script, setOf("*"))
                    scriptAdded = true
                }
                val client = HorizontWebViewClient(id, view.webViewClient, ::send)
                client.blocking = call.argument<Boolean>("blocking") ?: false
                view.webViewClient = client
                clients[id] = client
                val chrome = view.webChromeClient
                if (chrome != null) {
                    view.settings.setSupportMultipleWindows(true)
                    view.webChromeClient = HorizontChromeClient(id, chrome, ::send)
                }
                if (supported(WebViewFeature.SAFE_BROWSING_ENABLE)) {
                    WebSettingsCompat.setSafeBrowsingEnabled(
                        view.settings,
                        call.argument<Boolean>("safeBrowsing") ?: true,
                    )
                }
                view.settings.setSupportZoom(true)
                view.settings.builtInZoomControls = true
                view.settings.displayZoomControls = false
                view.setFindListener { active, count, done ->
                    send("onFind", mapOf("identifier" to id, "active" to active, "count" to count, "done" to done))
                }
                view.setDownloadListener { url, userAgent, disposition, mime, length ->
                    send(
                        "onDownload",
                        mapOf(
                            "identifier" to id,
                            "url" to url,
                            "userAgent" to userAgent,
                            "contentDisposition" to disposition,
                            "mimeType" to mime,
                            "contentLength" to length,
                            "cookies" to CookieManager.getInstance().getCookie(url),
                        ),
                    )
                }
                result.success(mapOf("found" to true, "profile" to profileSet, "script" to scriptAdded))
            }
            "release" -> {
                identifier(call)?.let { clients.remove(it) }
                result.success(null)
            }
            "addDocumentStartScript" -> {
                val view = webView(call)
                val script = call.argument<String>("script")
                if (view == null || script == null || !supported(WebViewFeature.DOCUMENT_START_SCRIPT)) {
                    result.success(false)
                } else {
                    WebViewCompat.addDocumentStartJavaScript(view, script, setOf("*"))
                    result.success(true)
                }
            }
            "capture" -> {
                val view = webView(call)
                val width = call.argument<Number>("width")?.toInt()
                if (view == null || width == null) result.success(null)
                else result.success(capture(view, width))
            }
            "captureTop" -> result.success(webView(call)?.let { captureTop(it) })
            "find" -> {
                webView(call)?.findAllAsync(call.argument<String>("text") ?: "")
                result.success(null)
            }
            "findNext" -> {
                webView(call)?.findNext(call.argument<Boolean>("forward") ?: true)
                result.success(null)
            }
            "clearMatches" -> {
                webView(call)?.clearMatches()
                result.success(null)
            }
            "setDesktopMode" -> {
                val view = webView(call)
                val on = call.argument<Boolean>("on") ?: false
                if (view != null) {
                    view.settings.useWideViewPort = true
                    view.settings.loadWithOverviewMode = on
                }
                result.success(null)
            }
            "setBlocking" -> {
                identifier(call)?.let { clients[it]?.blocking = call.argument<Boolean>("on") ?: false }
                result.success(null)
            }
            "setSafeBrowsing" -> {
                val view = webView(call)
                if (view != null && supported(WebViewFeature.SAFE_BROWSING_ENABLE)) {
                    WebSettingsCompat.setSafeBrowsingEnabled(view.settings, call.argument<Boolean>("on") ?: true)
                }
                result.success(null)
            }
            "setNightMode" -> {
                val context = binding?.applicationContext
                val manager = context?.getSystemService(Context.UI_MODE_SERVICE) as? UiModeManager
                val mode = when (call.argument<String>("mode")) {
                    "light" -> UiModeManager.MODE_NIGHT_NO
                    "dark" -> UiModeManager.MODE_NIGHT_YES
                    else -> UiModeManager.MODE_NIGHT_AUTO
                }
                manager?.setApplicationNightMode(mode)
                result.success(null)
            }
            "saveWebArchive" -> {
                val view = webView(call)
                val path = call.argument<String>("path")
                if (view == null || path == null) {
                    result.success(null)
                } else {
                    view.saveWebArchive(path, false) { saved -> result.success(saved) }
                }
            }
            "cookies" -> result.success(CookieManager.getInstance().getCookie(call.argument<String>("url")))
            "clearProfile" -> {
                val name = call.argument<String>("name")
                if (name != null && supported(WebViewFeature.MULTI_PROFILE)) {
                    val profile = ProfileStore.getInstance().getProfile(name)
                    profile?.cookieManager?.removeAllCookies(null)
                    profile?.webStorage?.deleteAllData()
                }
                result.success(null)
            }
            // Profiles of earlier private sessions; the one in use is kept.
            "deleteProfiles" -> {
                val prefix = call.argument<String>("prefix") ?: ""
                val keep = call.argument<String>("keep")
                var deleted = 0
                if (supported(WebViewFeature.MULTI_PROFILE)) {
                    val store = ProfileStore.getInstance()
                    for (name in store.allProfileNames) {
                        if (!name.startsWith(prefix) || name == keep) continue
                        try {
                            if (store.deleteProfile(name)) deleted++
                        } catch (_: IllegalStateException) {
                            // Still used by a view; the next start deletes it.
                        }
                    }
                }
                result.success(deleted)
            }
            "clearAllData" -> {
                CookieManager.getInstance().removeAllCookies(null)
                android.webkit.WebStorage.getInstance().deleteAllData()
                webView(call)?.clearCache(true)
                result.success(null)
            }
            "share" -> {
                val text = call.argument<String>("text") ?: ""
                val send = Intent(Intent.ACTION_SEND).apply {
                    type = "text/plain"
                    putExtra(Intent.EXTRA_TEXT, text)
                    call.argument<String>("subject")?.let { putExtra(Intent.EXTRA_SUBJECT, it) }
                }
                startActivity(Intent.createChooser(send, null))
                result.success(true)
            }
            "openExternal" -> result.success(openExternal(call.argument<String>("uri") ?: ""))
            "pinShortcut" -> result.success(pinShortcut(call))
            "openPasswordSettings" -> {
                val opened = startActivity(Intent("android.settings.CREDENTIAL_PROVIDER")) ||
                    startActivity(Intent(Settings.ACTION_REQUEST_SET_AUTOFILL_SERVICE).setData(Uri.parse("package:${binding?.applicationContext?.packageName}"))) ||
                    startActivity(Intent(Settings.ACTION_SETTINGS))
                result.success(opened)
            }
            "openDefaultBrowserSettings" -> {
                result.success(
                    startActivity(Intent(Settings.ACTION_MANAGE_DEFAULT_APPS_SETTINGS)) ||
                        startActivity(Intent(Settings.ACTION_SETTINGS)),
                )
            }
            "requestPermissions" -> {
                val names = call.argument<List<String>>("permissions") ?: emptyList()
                val activity = activity?.activity
                if (activity == null) {
                    result.success(names.associateWith { false })
                    return
                }
                val missing = names.filter {
                    activity.checkSelfPermission(it) != PackageManager.PERMISSION_GRANTED
                }
                if (missing.isEmpty()) {
                    result.success(names.associateWith { true })
                    return
                }
                pendingPermissions?.success(emptyMap<String, Boolean>())
                pendingPermissions = result
                activity.requestPermissions(missing.toTypedArray(), PERMISSION_REQUEST)
            }
            "initialUrl" -> {
                result.success(initialUrl)
                initialUrl = null
            }
            else -> result.notImplemented()
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ): Boolean {
        if (requestCode != PERMISSION_REQUEST) return false
        val answer = permissions.indices.associate { permissions[it] to (grantResults[it] == PackageManager.PERMISSION_GRANTED) }
        pendingPermissions?.success(answer)
        pendingPermissions = null
        return true
    }

    private fun startActivity(intent: Intent): Boolean {
        val activity: Activity = activity?.activity ?: return false
        return try {
            activity.startActivity(intent)
            true
        } catch (_: ActivityNotFoundException) {
            false
        } catch (_: SecurityException) {
            false
        }
    }

    /**
     * Hands a link a page wanted to open in another app to Android. `intent:`
     * links lose any component and selector so a page cannot target a
     * private activity; when no app takes them, their fallback URL is
     * returned for the browser to load.
     */
    private fun openExternal(uri: String): Map<String, Any?> {
        val intent = try {
            if (uri.startsWith("intent:")) {
                Intent.parseUri(uri, Intent.URI_INTENT_SCHEME).apply {
                    addCategory(Intent.CATEGORY_BROWSABLE)
                    component = null
                    selector = null
                }
            } else {
                Intent(Intent.ACTION_VIEW, Uri.parse(uri)).addCategory(Intent.CATEGORY_BROWSABLE)
            }
        } catch (_: Exception) {
            return mapOf("opened" to false)
        }
        val fallback = intent.getStringExtra("browser_fallback_url")
        val opened = startActivity(intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
        return mapOf("opened" to opened, "fallback" to fallback)
    }

    /** Asks the launcher to pin a shortcut that opens [url] in Horizont. */
    private fun pinShortcut(call: MethodCall): Boolean {
        val context = binding?.applicationContext ?: return false
        val manager = context.getSystemService(ShortcutManager::class.java) ?: return false
        if (!manager.isRequestPinShortcutSupported) return false
        val url = call.argument<String>("url") ?: return false
        val title = call.argument<String>("title")?.ifBlank { null } ?: Uri.parse(url).host ?: url
        val letter = call.argument<String>("letter") ?: title.take(1).uppercase()
        val fill = call.argument<Number>("background")?.toInt() ?: 0xFFD8E2FF.toInt()
        val ink = call.argument<Number>("foreground")?.toInt() ?: 0xFF001A41.toInt()
        val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url)).setClass(context, MainActivity::class.java)
        val info = ShortcutInfo.Builder(context, "page-" + url.hashCode())
            .setShortLabel(title.take(24))
            .setLongLabel(title.take(60))
            .setIcon(Icon.createWithAdaptiveBitmap(monogram(letter, fill, ink)))
            .setIntent(intent)
            .build()
        return manager.requestPinShortcut(info, null)
    }

    /** A letter on a full-bleed square, for an adaptive icon (108 dp art). */
    private fun monogram(letter: String, fill: Int, ink: Int): Bitmap {
        val size = 432
        val bitmap = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        canvas.drawColor(fill)
        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = ink
            textSize = size * 0.34f
            textAlign = Paint.Align.CENTER
            typeface = Typeface.create(Typeface.DEFAULT, 800, false)
        }
        val y = size / 2f - (paint.descent() + paint.ascent()) / 2f
        canvas.drawText(letter, size / 2f, y, paint)
        return bitmap
    }

    /** What [view] shows, scaled to [targetWidth] pixels wide, as lossy WebP. */
    private fun capture(view: WebView, targetWidth: Int): ByteArray? {
        val width = view.width
        val height = view.height
        if (width <= 0 || height <= 0 || targetWidth <= 0) return null
        val scale = targetWidth / width.toFloat()
        val bitmap = Bitmap.createBitmap(
            targetWidth,
            maxOf(1, (height * scale).toInt()),
            Bitmap.Config.ARGB_8888,
        )
        try {
            val canvas = Canvas(bitmap)
            canvas.scale(scale, scale)
            view.draw(canvas)
            val out = java.io.ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.WEBP_LOSSY, 70, out)
            return out.toByteArray()
        } finally {
            bitmap.recycle()
        }
    }

    /** Average colour of the top rows of [view] as 0xAARRGGBB, or null. */
    private fun captureTop(view: WebView): Long? {
        val width = view.width
        if (width <= 0 || view.height <= 0) return null
        val scale = 0.1f
        val bitmapWidth = maxOf(1, (width * scale).toInt())
        val rows = 4
        val bitmap = Bitmap.createBitmap(bitmapWidth, rows, Bitmap.Config.ARGB_8888)
        try {
            val canvas = Canvas(bitmap)
            canvas.scale(bitmapWidth / width.toFloat(), bitmapWidth / width.toFloat())
            view.draw(canvas)
            var a = 0L; var r = 0L; var g = 0L; var b = 0L
            val pixels = IntArray(bitmapWidth * rows)
            bitmap.getPixels(pixels, 0, bitmapWidth, 0, 0, bitmapWidth, rows)
            for (p in pixels) {
                a += (p ushr 24) and 0xFF; r += (p shr 16) and 0xFF
                g += (p shr 8) and 0xFF; b += p and 0xFF
            }
            val n = pixels.size
            return ((a / n) shl 24) or ((r / n) shl 16) or ((g / n) shl 8) or (b / n)
        } finally {
            bitmap.recycle()
        }
    }

    companion object {
        private const val PERMISSION_REQUEST = 0x4857
    }
}
