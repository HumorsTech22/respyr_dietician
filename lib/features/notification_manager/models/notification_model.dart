class NotificationModel {
  final int id;
  final String title;
  final String message;
  final String notificationType;
  final String targetId;
  final String actionType;
  final Map<String, dynamic> actionPayload;
  final String? scheduledTime;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.notificationType,
    required this.targetId,
    required this.actionType,
    required this.actionPayload,
    required this.scheduledTime,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      notificationType: json['notification_type'],
      targetId: json['target_id'],
      actionType: json['action_type'],
      actionPayload: Map<String, dynamic>.from(json['action_payload'] ?? {}),
      scheduledTime: json['scheduled_time'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
