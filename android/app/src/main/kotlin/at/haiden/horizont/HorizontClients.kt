package at.haiden.horizont

import android.content.Context
import android.graphics.Bitmap
import android.net.Uri
import android.net.http.SslError
import android.os.Handler
import android.os.Looper
import android.os.Message
import android.view.KeyEvent
import android.view.View
import android.webkit.ClientCertRequest
import android.webkit.ConsoleMessage
import android.webkit.GeolocationPermissions
import android.webkit.HttpAuthHandler
import android.webkit.JsPromptResult
import android.webkit.JsResult
import android.webkit.PermissionRequest
import android.webkit.RenderProcessGoneDetail
import android.webkit.SslErrorHandler
import android.webkit.ValueCallback
import android.webkit.WebChromeClient
import android.webkit.WebResourceError
import android.webkit.WebResourceRequest
import android.webkit.WebResourceResponse
import android.webkit.WebView
import android.webkit.WebViewClient
import io.flutter.plugins.webviewflutter.WebChromeClientProxyApi
import java.io.ByteArrayInputStream
import java.util.concurrent.ConcurrentHashMap

typealias Sender = (String, Map<String, Any?>) -> Unit

/**
 * The plugin's [WebViewClient] with two additions: requests to known trackers
 * are answered empty (EasyPrivacy, D6), and a crashed renderer is reported
 * instead of taking the app down. Every other callback goes to the plugin's
 * client unchanged (spike in `docs/spikes.md`).
 */
class HorizontWebViewClient(
    private val id: Long,
    private val inner: WebViewClient,
    private val send: Sender,
) : WebViewClient() {
    @Volatile var blocking = false
    @Volatile private var pageHost: String? = null
    private val counts = ConcurrentHashMap<String, Int>()
    private val main = Handler(Looper.getMainLooper())
    private var flushPending = false

    private fun track(url: String?) {
        pageHost = url?.let { Uri.parse(it).host }
    }

    override fun shouldInterceptRequest(view: WebView, request: WebResourceRequest): WebResourceResponse? {
        if (blocking && !request.isForMainFrame) {
            val host = request.url.host
            val page = pageHost
            if (host != null && page != null && Blocklist.isThirdParty(host, page) && Blocklist.blocks(host)) {
                counts.merge(host, 1, Int::plus)
                scheduleFlush()
                return WebResourceResponse("text/plain", "utf-8", 204, "Blocked", emptyMap(), ByteArrayInputStream(ByteArray(0)))
            }
        }
        return inner.shouldInterceptRequest(view, request)
    }

    /** Counts go to Dart at most once a second. */
    private fun scheduleFlush() {
        main.post {
            if (flushPending) return@post
            flushPending = true
            main.postDelayed({
                flushPending = false
                val snapshot = HashMap(counts)
                counts.clear()
                if (snapshot.isNotEmpty()) {
                    send("onBlocked", mapOf("identifier" to id, "pageHost" to pageHost, "counts" to snapshot))
                }
            }, 1000)
        }
    }

    override fun onRenderProcessGone(view: WebView, detail: RenderProcessGoneDetail): Boolean {
        send("onRenderGone", mapOf("identifier" to id, "crashed" to detail.didCrash()))
        return true
    }

    override fun onPageStarted(view: WebView, url: String, favicon: Bitmap?) {
        track(url)
        inner.onPageStarted(view, url, favicon)
    }

    override fun onPageFinished(view: WebView, url: String) = inner.onPageFinished(view, url)

    override fun onReceivedHttpError(view: WebView, request: WebResourceRequest, response: WebResourceResponse) =
        inner.onReceivedHttpError(view, request, response)

    override fun onReceivedError(view: WebView, request: WebResourceRequest, error: WebResourceError) =
        inner.onReceivedError(view, request, error)

    override fun shouldOverrideUrlLoading(view: WebView, request: WebResourceRequest): Boolean =
        inner.shouldOverrideUrlLoading(view, request)

    override fun doUpdateVisitedHistory(view: WebView, url: String, isReload: Boolean) {
        track(url)
        inner.doUpdateVisitedHistory(view, url, isReload)
    }

    override fun onReceivedHttpAuthRequest(view: WebView, handler: HttpAuthHandler, host: String, realm: String) =
        inner.onReceivedHttpAuthRequest(view, handler, host, realm)

    override fun onFormResubmission(view: WebView, dontResend: Message, resend: Message) =
        inner.onFormResubmission(view, dontResend, resend)

    override fun onLoadResource(view: WebView, url: String) = inner.onLoadResource(view, url)

    override fun onPageCommitVisible(view: WebView, url: String) = inner.onPageCommitVisible(view, url)

    override fun onReceivedClientCertRequest(view: WebView, request: ClientCertRequest) =
        inner.onReceivedClientCertRequest(view, request)

    override fun onReceivedLoginRequest(view: WebView, realm: String, account: String?, args: String) =
        inner.onReceivedLoginRequest(view, realm, account, args)

    override fun onReceivedSslError(view: WebView, handler: SslErrorHandler, error: SslError) =
        inner.onReceivedSslError(view, handler, error)

    override fun onScaleChanged(view: WebView, oldScale: Float, newScale: Float) =
        inner.onScaleChanged(view, oldScale, newScale)

    override fun onUnhandledKeyEvent(view: WebView, event: KeyEvent) = inner.onUnhandledKeyEvent(view, event)
}

/**
 * The plugin's [WebChromeClient] (it must stay a `SecureWebChromeClient`)
 * with `window.open` and `target=_blank` turned into a request for a new tab:
 * a throwaway view catches the first address and is destroyed.
 */
class HorizontChromeClient(
    private val id: Long,
    private val inner: WebChromeClient,
    private val send: Sender,
) : WebChromeClientProxyApi.SecureWebChromeClient() {
    override fun onCreateWindow(view: WebView, isDialog: Boolean, isUserGesture: Boolean, resultMsg: Message): Boolean {
        val catcher = WebView(view.context)
        catcher.webViewClient = object : WebViewClient() {
            private var done = false

            private fun take(url: String?) {
                if (done || url == null || url == "about:blank") return
                done = true
                send("onNewWindow", mapOf("identifier" to id, "url" to url, "userGesture" to isUserGesture))
                catcher.post { catcher.destroy() }
            }

            override fun shouldOverrideUrlLoading(v: WebView, request: WebResourceRequest): Boolean {
                take(request.url.toString())
                return true
            }

            override fun onPageStarted(v: WebView, url: String, favicon: Bitmap?) {
                take(url)
                v.stopLoading()
            }
        }
        val transport = resultMsg.obj as WebView.WebViewTransport
        transport.webView = catcher
        resultMsg.sendToTarget()
        return true
    }

    override fun onProgressChanged(view: WebView, newProgress: Int) = inner.onProgressChanged(view, newProgress)

    override fun onReceivedTitle(view: WebView, title: String?) = inner.onReceivedTitle(view, title)

    override fun onShowCustomView(view: View, callback: CustomViewCallback) = inner.onShowCustomView(view, callback)

    override fun onHideCustomView() = inner.onHideCustomView()

    override fun onGeolocationPermissionsShowPrompt(origin: String, callback: GeolocationPermissions.Callback) =
        inner.onGeolocationPermissionsShowPrompt(origin, callback)

    override fun onGeolocationPermissionsHidePrompt() = inner.onGeolocationPermissionsHidePrompt()

    override fun onShowFileChooser(
        webView: WebView,
        filePathCallback: ValueCallback<Array<Uri>>,
        fileChooserParams: FileChooserParams,
    ): Boolean = inner.onShowFileChooser(webView, filePathCallback, fileChooserParams)

    override fun onPermissionRequest(request: PermissionRequest) = inner.onPermissionRequest(request)

    override fun onPermissionRequestCanceled(request: PermissionRequest) = inner.onPermissionRequestCanceled(request)

    override fun onConsoleMessage(consoleMessage: ConsoleMessage): Boolean = inner.onConsoleMessage(consoleMessage)

    override fun onJsAlert(view: WebView, url: String, message: String, result: JsResult): Boolean =
        inner.onJsAlert(view, url, message, result)

    override fun onJsConfirm(view: WebView, url: String, message: String, result: JsResult): Boolean =
        inner.onJsConfirm(view, url, message, result)

    override fun onJsPrompt(view: WebView, url: String, message: String, defaultValue: String?, result: JsPromptResult): Boolean =
        inner.onJsPrompt(view, url, message, defaultValue, result)

    override fun onJsBeforeUnload(view: WebView, url: String, message: String, result: JsResult): Boolean =
        inner.onJsBeforeUnload(view, url, message, result)

    override fun onCloseWindow(window: WebView) = inner.onCloseWindow(window)

    override fun onRequestFocus(view: WebView) = inner.onRequestFocus(view)

    override fun getDefaultVideoPoster(): Bitmap? = inner.defaultVideoPoster

    override fun getVideoLoadingProgressView(): View? = inner.videoLoadingProgressView
}

/**
 * The tracker domains of EasyPrivacy, reduced to plain `||domain^` rules by
 * `tool/gen_blocklist.dart`. A request is blocked when its host or a parent
 * domain is listed and it goes to another site than the page.
 */
object Blocklist {
    @Volatile private var domains: Set<String> = emptySet()

    fun load(context: Context, assetPath: String) {
        try {
            val set = HashSet<String>(65536)
            context.assets.open(assetPath).bufferedReader().useLines { lines ->
                for (line in lines) if (line.isNotBlank()) set.add(line.trim())
            }
            domains = set
        } catch (_: Exception) {
            domains = emptySet()
        }
    }

    fun blocks(host: String): Boolean {
        val set = domains
        if (set.isEmpty()) return false
        var h = host.lowercase()
        while (true) {
            if (set.contains(h)) return true
            val dot = h.indexOf('.')
            if (dot < 0 || dot == h.length - 1) return false
            h = h.substring(dot + 1)
            if (!h.contains('.')) return false
        }
    }

    /** Hosts on different sites; the site is approximated by the last two labels. */
    fun isThirdParty(host: String, page: String): Boolean = site(host) != site(page)

    private fun site(host: String): String {
        val parts = host.lowercase().trimEnd('.').split('.')
        return if (parts.size <= 2) parts.joinToString(".") else parts.takeLast(2).joinToString(".")
    }
}
