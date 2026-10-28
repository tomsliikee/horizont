package at.haiden.horizont

import android.app.Activity
import android.content.ClipDescription
import android.content.ClipboardManager
import android.content.Context
import android.view.textclassifier.TextClassifier
import com.google.mlkit.vision.barcode.common.Barcode
import com.google.mlkit.vision.codescanner.GmsBarcodeScannerOptions
import com.google.mlkit.vision.codescanner.GmsBarcodeScanning

/**
 * The start page's quick actions that need Android: the QR scanner of Play
 * services (its own screen, no camera permission for the app) and a look at
 * the clipboard that does not read it.
 */
object QuickActions {
    /** Scans one code; [done] gets its text, or null when cancelled or failed. */
    fun scanQr(activity: Activity, done: (String?) -> Unit) {
        val options = GmsBarcodeScannerOptions.Builder()
            .setBarcodeFormats(Barcode.FORMAT_QR_CODE)
            .build()
        GmsBarcodeScanning.getClient(activity, options)
            .startScan()
            .addOnSuccessListener { done(it.url?.url ?: it.rawValue) }
            .addOnCanceledListener { done(null) }
            .addOnFailureListener { done(null) }
    }

    /**
     * Whether the clipboard holds a link, from the system's classification of
     * the clip. Only the description is read, so Android shows no "pasted"
     * notice; that comes when [clipText] reads it on a tap.
     */
    fun clipHasLink(context: Context): Boolean {
        val description = clipboard(context)?.primaryClipDescription ?: return false
        if (!description.hasMimeType(ClipDescription.MIMETYPE_TEXT_PLAIN) &&
            !description.hasMimeType(ClipDescription.MIMETYPE_TEXT_URILIST)
        ) {
            return false
        }
        if (description.classificationStatus != ClipDescription.CLASSIFICATION_COMPLETE) return false
        return description.getConfidenceScore(TextClassifier.TYPE_URL) >= 0.5f
    }

    fun clipText(context: Context): String? =
        clipboard(context)?.primaryClip?.takeIf { it.itemCount > 0 }
            ?.getItemAt(0)?.coerceToText(context)?.toString()

    private fun clipboard(context: Context) =
        context.getSystemService(ClipboardManager::class.java)
}
