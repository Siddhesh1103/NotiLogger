
import 'package:flutter/services.dart';
import 'notification_model.dart';

class NotificationService {
  static const MethodChannel _channel =
      MethodChannel('com.example.notilogger/notifications');

  Future<List<NotificationModel>> getNotifications() async {
    final List<dynamic> result =
        await _channel.invokeMethod('getNotifications');

    return result
        .map((item) => NotificationModel.fromMap(
              Map<dynamic, dynamic>.from(item),
            ))
        .toList();
  }
    
    Future<void> deleteAllNotifications() async {
        await _channel.invokeMethod('deleteAllNotifications');
    }
}