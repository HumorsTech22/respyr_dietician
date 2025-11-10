import 'dart:convert';
import 'package:http/http.dart' as http;
import 'diet_models.dart';

class DietApi {
  static const _url = 'https://humorstech.com/dietitian/api/app/app/get_diet.php';

  static Future<DietDay> fetchDietDay({
    required String loginId,
    required String profileId,
    required String day, // e.g., 'monday'
  }) async {
    final resp = await http.post(
      Uri.parse(_url),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'login_id': loginId,
        'profile_id': profileId,
        'day': day.toLowerCase(),
      },
    );

    if (resp.statusCode != 200) {
      throw Exception('HTTP ${resp.statusCode}');
    }

    final Map<String, dynamic> jsonMap = json.decode(resp.body);

    // Response has top-level keys for days. Extract the one we asked for.
    final dayJson = jsonMap[day.toLowerCase()];
    if (dayJson == null) {
      throw Exception('Day "$day" not found in response');
    }
    return DietDay.fromJson(dayJson as Map<String, dynamic>);
  }
}
