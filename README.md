# NotiLogger 🔔

### Because some friends send messages and then pretend they never existed. 👀

We've all had that one friend who sends a message and deletes it a few seconds later. That got me thinking: what if I could save the content of a notification before it disappears?

That's how **NotiLogger** was born — a simple Android app that captures notification content and stores it locally, so you can look back at notifications even after they've been dismissed.

## ✨ Features

- **Notification Logging:** Saves notification content locally on your device.
- **Search:** Find saved notifications by message or app name.
- **App Filtering:** Filter notifications by the app they came from.
- **72-Hour Retention:** Automatically removes older records.
- **Privacy-Focused Storage:** No backend or cloud database.

## 🛠️ Built With

- Flutter & Dart
- Kotlin
- Android Notification Listener Service
- Room Database (SQLite)

## 🎯 Why I Built It

A small, relatable problem turned into an opportunity to learn Android notification handling, local database storage, native Kotlin integration, and Flutter development.

**Note:** NotiLogger can only save content made available through Android notifications. It cannot directly retrieve deleted messages from WhatsApp.

*Built as a personal learning project.*
