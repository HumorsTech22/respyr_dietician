import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notification_model.dart';

class NotificationRepository {
  final String apiUrl = 'https://humorstech.com/humors_app/app_final/dieticianapp/api/fetch_notifications.php';

  Future<List<NotificationModel>> fetchNotifications(String targetId) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      body: {'target_id': targetId},
    );

    final data = jsonDecode(response.body);
    if (data['success'] == true) {
      List notifications = data['data'];
      return notifications
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } else {
      throw Exception(data['message'] ?? 'Failed to load notifications');
    }
  }
}
