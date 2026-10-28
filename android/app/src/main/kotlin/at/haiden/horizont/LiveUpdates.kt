package at.haiden.horizont

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.graphics.drawable.Icon
import android.os.Build

/**
 * Ongoing notifications with progress. On Android 16 and newer they ask to be
 * promoted to a Live Update (status bar chip, lock screen); older versions
 * show a normal ongoing notification with a progress bar.
 */
object LiveUpdates {
    private const val CHANNEL = "horizont_live"
    const val ACTION = "at.haiden.horizont.LIVE_ACTION"

    /** Set by the plugin while a Flutter engine listens; null when the app is closed. */
    var onAction: ((id: Int, action: String, payload: String) -> Unit)? = null

    private fun manager(context: Context): NotificationManager {
        val manager = context.getSystemService(NotificationManager::class.java)
        if (manager.getNotificationChannel(CHANNEL) == null) {
            manager.createNotificationChannel(
                NotificationChannel(
                    CHANNEL,
                    context.getString(R.string.live_channel),
                    NotificationManager.IMPORTANCE_LOW,
                ),
            )
        }
        return manager
    }

    /**
     * Shows or updates notification [id]. [progress] is 0 to 100, or negative
     * while the size is unknown. [actions] are (label, action name) pairs sent
     * back to Dart with [payload] when tapped.
     */
    fun show(
        context: Context,
        id: Int,
        title: String,
        text: String,
        progress: Int,
        chip: String?,
        actions: List<Pair<String, String>>,
        payload: String,
    ) {
        val builder = Notification.Builder(context, CHANNEL)
            .setSmallIcon(Icon.createWithResource(context, R.drawable.ic_stat_download))
            .setContentTitle(title)
            .setContentText(text)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setCategory(Notification.CATEGORY_PROGRESS)
            .setContentIntent(launchIntent(context))
        val style = Notification.ProgressStyle()
            .setProgressIndeterminate(progress < 0)
            .setProgress(progress.coerceAtLeast(0))
        if (Build.VERSION.SDK_INT >= 36) {
            builder.setStyle(style)
            // The platform 36 stubs have no setter for the request; the
            // extra is what it reads (EXTRA_REQUEST_PROMOTED_ONGOING).
            builder.addExtras(android.os.Bundle().apply { putBoolean("android.requestPromotedOngoing", true) })
            if (chip != null) builder.setShortCriticalText(chip)
        } else {
            builder.setProgress(100, progress.coerceAtLeast(0), progress < 0)
        }
        for ((label, action) in actions) {
            builder.addAction(
                Notification.Action.Builder(null, label, actionIntent(context, id, action, payload)).build(),
            )
        }
        manager(context).notify(id, builder.build())
    }

    fun cancel(context: Context, id: Int) = manager(context).cancel(id)

    private fun launchIntent(context: Context): PendingIntent {
        val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)
        return PendingIntent.getActivity(context, 0, intent, PendingIntent.FLAG_IMMUTABLE)
    }

    private fun actionIntent(context: Context, id: Int, action: String, payload: String): PendingIntent {
        val intent = Intent(context, LiveActionReceiver::class.java)
            .setAction(ACTION)
            .putExtra("id", id)
            .putExtra("action", action)
            .putExtra("payload", payload)
        // The request code keeps one pending intent per notification and action.
        return PendingIntent.getBroadcast(
            context,
            id * 31 + action.hashCode(),
            intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
    }
}

/** Hands a tap on a notification action to Dart, if the app is running. */
class LiveActionReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        LiveUpdates.onAction?.invoke(
            intent.getIntExtra("id", 0),
            intent.getStringExtra("action") ?: return,
            intent.getStringExtra("payload") ?: "",
        )
    }
}
