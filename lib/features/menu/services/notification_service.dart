import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationService {
  Future<bool> updateNotification({
    required String profileId,
    required bool isEnabled,
  }) async {
    try {
      print("profileId: $profileId");
      print("isEnabled: $isEnabled");
      print("sending value: ${isEnabled ? '1' : '0'}");

      final response = await http.post(
        Uri.parse(
          'https://humorstech.com/humors_app/app_final/dieticianapp/api/update_notification_status.php',
        ),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'profile_id': profileId,
          'is_notification_enabled': isEnabled ? '1' : '0',
        },
      );

      print("STATUS CODE => ${response.statusCode}");
      print("RAW BODY => ${response.body}");

      if (response.statusCode != 200) {
        return false;
      }

      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded['status']?.toString().toLowerCase() == 'success';
      }

      return false;
    } catch (e) {
      print("updateNotification error => $e");
      return false;
    }
  }
}