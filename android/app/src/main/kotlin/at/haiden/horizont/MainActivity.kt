package at.haiden.horizont

import android.os.Build
import android.os.Bundle
import android.view.View
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine

/** A fragment activity, because the fingerprint prompt of `local_auth` needs one. */
class MainActivity : FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Flutter never says how fast it wants to draw, so the adaptive
        // display (30 to 120 Hz on the Pixel) settles on a low rate while
        // an animation runs without a finger on the screen.
        val params = window.attributes
        params.preferredRefreshRate = 120f
        window.attributes = params
        if (Build.VERSION.SDK_INT >= 35) {
            window.decorView.requestedFrameRate = View.REQUESTED_FRAME_RATE_CATEGORY_HIGH
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.plugins.add(HorizontWebKitPlugin())
    }
}
