
package com.example.notilogger

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.example.notilogger/notifications"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            when (call.method) {
                "getNotifications" -> {
                    CoroutineScope(Dispatchers.IO).launch {
                        try {

                            val db = DatabaseProvider.getDatabase(
                                applicationContext
                            )

                            val cutoff = System.currentTimeMillis() -
                            (72L * 60 * 60 * 1000)

                            db.notificationDao().deleteOlderThan(cutoff)

                            val notifications =
                                db.notificationDao().getAllNotifications()

                            val response = notifications.map { notification ->
                                mapOf(
                                    "id" to notification.id,
                                    "appName" to notification.appName,
                                    "packageName" to notification.packageName,
                                    "sender" to notification.sender,
                                    "message" to notification.message,
                                    "timestamp" to notification.timestamp
                                )
                            }

                            withContext(Dispatchers.Main) {
                                result.success(response)
                            }
                        } catch (e: Exception) {
                            withContext(Dispatchers.Main) {
                                result.error(
                                    "DATABASE_ERROR",
                                    e.message,
                                    null
                                )
                            }
                        }
                    }
                }

                                    
                    "deleteAllNotifications" -> {
                        CoroutineScope(Dispatchers.IO).launch {
                            try {
                                val db = DatabaseProvider.getDatabase(
                                    applicationContext
                                )

                                db.notificationDao().deleteAll()

                                withContext(Dispatchers.Main) {
                                    result.success(true)
                                }
                            } catch (e: Exception) {
                                withContext(Dispatchers.Main) {
                                    result.error(
                                        "DATABASE_ERROR",
                                        e.message,
                                        null
                                    )
                                }
                            }
                        }
                    }

                else -> result.notImplemented()
            }
        }
    }
}