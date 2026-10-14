
class NotificationModel {
  final int id;
  final String appName;
  final String packageName;
  final String? sender;
  final String? message;
  final int timestamp;

  NotificationModel({
    required this.id,
    required this.appName,
    required this.packageName,
    this.sender,
    this.message,
    required this.timestamp,
  });

  factory NotificationModel.fromMap(Map<dynamic, dynamic> map) {
    return NotificationModel(
      id: map['id'] as int,
      appName: map['appName'] as String,
      packageName: map['packageName'] as String,
      sender: map['sender'] as String?,
      message: map['message'] as String?,
      timestamp: map['timestamp'] as int,
    );
  }
}