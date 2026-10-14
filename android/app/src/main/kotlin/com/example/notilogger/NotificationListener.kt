package com.example.notilogger

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch

class NotificationListener : NotificationListenerService() {

    private val serviceScope =
        CoroutineScope(SupervisorJob() + Dispatchers.IO)

    override fun onNotificationPosted(sbn: StatusBarNotification) {
        super.onNotificationPosted(sbn)

        try {
            val packageName = sbn.packageName

            val appInfo = packageManager.getApplicationInfo(packageName, 0)
            val appName =
                packageManager.getApplicationLabel(appInfo).toString()

            val extras = sbn.notification.extras
            val title = extras.getCharSequence("android.title")?.toString()
            val text = extras.getCharSequence("android.text")?.toString()
            val timestamp = sbn.postTime

            val notification = NotificationEntity(
                appName = appName,
                packageName = packageName,
                sender = title,
                message = text,
                timestamp = timestamp
            )

            serviceScope.launch {
                try {
                    val db = DatabaseProvider.getDatabase(applicationContext)

                    db.notificationDao().insert(notification)

                    // Remove notifications older than 72 hours.
                    val cutoff = System.currentTimeMillis() -
                        (72L * 60 * 60 * 1000)

                    db.notificationDao().deleteOlderThan(cutoff)

                    android.util.Log.d(
                        "NotiLogger",
                        "Saved notification from $appName"
                    )
                } catch (e: Exception) {
                    android.util.Log.e(
                        "NotiLogger",
                        "Failed to save notification",
                        e
                    )
                }
            }
        } catch (e: Exception) {
            android.util.Log.e(
                "NotiLogger",
                "Failed to read notification",
                e
            )
        }
    }

    override fun onDestroy() {
        serviceScope.cancel()
        super.onDestroy()
    }
}
