package com.example.notilogger

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "notifications")
data class NotificationEntity(

    @PrimaryKey(autoGenerate = true)
    val id: Long = 0,

    val appName: String,
    val packageName: String,
    val sender: String?,
    val message: String?,
    val timestamp: Long
)