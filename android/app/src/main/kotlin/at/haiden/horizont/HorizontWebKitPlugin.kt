package at.haiden.horizont

import android.graphics.Bitmap
import android.graphics.Canvas
import android.webkit.WebView
import androidx.webkit.WebViewCompat
import androidx.webkit.WebViewFeature
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.webviewflutter.WebViewFlutterAndroidExternalApi

/**
 * What `webview_flutter` does not expose, reached through the native `WebView`
 * that the plugin keeps under an identifier. `probe` (milestone 2), `addDocumentStartScript` and `captureTop` (milestone 3), `capture` (milestone 4).
 */
class HorizontWebKitPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private var binding: FlutterPlugin.FlutterPluginBinding? = null
    private var channel: MethodChannel? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        this.binding = binding
        channel = MethodChannel(binding.binaryMessenger, "at.haiden.horizont/webkit").also {
            it.setMethodCallHandler(this)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        channel = null
        this.binding = null
    }

    private fun webView(call: MethodCall): WebView? {
        val id = (call.argument<Number>("identifier") ?: return null).toLong()
        val binding = binding ?: return null
        return WebViewFlutterAndroidExternalApi.getWebView(binding, id)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "probe" -> {
                val view = webView(call)
                result.success(
                    mapOf(
                        "found" to (view != null),
                        "webViewClient" to view?.webViewClient?.javaClass?.name,
                        "features" to mapOf(
                            "MULTI_PROFILE" to WebViewFeature.isFeatureSupported(WebViewFeature.MULTI_PROFILE),
                            "DOCUMENT_START_SCRIPT" to WebViewFeature.isFeatureSupported(WebViewFeature.DOCUMENT_START_SCRIPT),
                            "SAFE_BROWSING_ENABLE" to WebViewFeature.isFeatureSupported(WebViewFeature.SAFE_BROWSING_ENABLE),
                            "ALGORITHMIC_DARKENING" to WebViewFeature.isFeatureSupported(WebViewFeature.ALGORITHMIC_DARKENING),
                            "WEB_AUTHENTICATION" to WebViewFeature.isFeatureSupported(WebViewFeature.WEB_AUTHENTICATION),
                        ),
                    ),
                )
            }
            "addDocumentStartScript" -> {
                val view = webView(call)
                val script = call.argument<String>("script")
                if (view == null || script == null ||
                    !WebViewFeature.isFeatureSupported(WebViewFeature.DOCUMENT_START_SCRIPT)
                ) {
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
            else -> result.notImplemented()
        }
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
}
