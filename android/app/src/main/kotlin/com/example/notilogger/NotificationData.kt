package com.example.notilogger

data class NotificationData(
    val appName: String,
    val packageName: String,
    val sender: String?,
    val message: String?,
    val timestamp: Long
)
