package at.haiden.horizont

import android.content.Context
import android.os.Build
import android.os.VibrationAttributes
import android.os.VibrationEffect
import android.os.VibrationEffect.Composition as C
import android.os.VibratorManager
import android.view.HapticFeedbackConstants
import android.view.View

/**
 * Touch feedback by meaning. Normal uses the system's own feedback
 * constants, which follow the "touch feedback" setting; strong composes
 * vibration primitives a little harder, where the vibrator has them.
 */
object Haptics {
    fun play(context: Context, view: View?, kind: String, strong: Boolean) {
        if (strong && compose(context, kind)) return
        view?.performHapticFeedback(constant(kind))
    }

    private fun constant(kind: String): Int {
        val modern = Build.VERSION.SDK_INT >= 34
        return when (kind) {
            "tap" -> HapticFeedbackConstants.KEYBOARD_TAP
            "tick" -> if (modern) HapticFeedbackConstants.SEGMENT_FREQUENT_TICK else HapticFeedbackConstants.CLOCK_TICK
            "threshold" -> if (modern) HapticFeedbackConstants.GESTURE_THRESHOLD_ACTIVATE else HapticFeedbackConstants.CONTEXT_CLICK
            "release" -> if (modern) HapticFeedbackConstants.GESTURE_THRESHOLD_DEACTIVATE else HapticFeedbackConstants.CLOCK_TICK
            "confirm" -> HapticFeedbackConstants.CONFIRM
            "reject" -> HapticFeedbackConstants.REJECT
            "toggleOn" -> if (modern) HapticFeedbackConstants.TOGGLE_ON else HapticFeedbackConstants.CLOCK_TICK
            "toggleOff" -> if (modern) HapticFeedbackConstants.TOGGLE_OFF else HapticFeedbackConstants.CLOCK_TICK
            "dragStart" -> if (modern) HapticFeedbackConstants.DRAG_START else HapticFeedbackConstants.LONG_PRESS
            else -> HapticFeedbackConstants.LONG_PRESS
        }
    }

    /** Plays [kind] as primitives; false where the vibrator lacks them. */
    private fun compose(context: Context, kind: String): Boolean {
        val vibrator = context.getSystemService(VibratorManager::class.java)?.defaultVibrator ?: return false
        val parts: List<Pair<Int, Float>> = when (kind) {
            "tap" -> listOf(C.PRIMITIVE_CLICK to 0.7f)
            "tick" -> listOf(C.PRIMITIVE_TICK to 0.9f)
            "threshold" -> listOf(C.PRIMITIVE_CLICK to 1f)
            "release" -> listOf(C.PRIMITIVE_TICK to 0.6f)
            "confirm" -> listOf(C.PRIMITIVE_CLICK to 0.6f, C.PRIMITIVE_CLICK to 1f)
            "reject" -> listOf(C.PRIMITIVE_THUD to 1f)
            "toggleOn" -> listOf(C.PRIMITIVE_QUICK_RISE to 0.8f)
            "toggleOff" -> listOf(C.PRIMITIVE_QUICK_FALL to 0.8f)
            "dragStart" -> listOf(C.PRIMITIVE_LOW_TICK to 1f)
            else -> listOf(C.PRIMITIVE_THUD to 0.8f)
        }
        if (!vibrator.areAllPrimitivesSupported(*parts.map { it.first }.toIntArray())) return false
        val effect = VibrationEffect.startComposition().apply {
            parts.forEachIndexed { i, (primitive, scale) -> addPrimitive(primitive, scale, if (i == 0) 0 else 60) }
        }.compose()
        if (Build.VERSION.SDK_INT >= 33) {
            // As touch feedback, so the system's touch intensity still applies.
            vibrator.vibrate(effect, VibrationAttributes.createForUsage(VibrationAttributes.USAGE_TOUCH))
        } else {
            vibrator.vibrate(effect)
        }
        return true
    }
}
