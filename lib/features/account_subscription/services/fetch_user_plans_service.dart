import 'dart:convert';
import 'package:http/http.dart' as http;

import '../data/model/fetch_plan_response.dart';

class FetchUserPlansService {
  static const String _url =
      'https://humorstech.com/dietitian/api/app/fetch_user_plans.php';

  static Future<FetchUserPlansResponse> fetchUserPlans({
    required String profileId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'profile_id': profileId,
        }),
      );

      if (response.statusCode != 200) {
        return FetchUserPlansResponse(
          status: false,
          message: 'Server error: ${response.statusCode}',
          data: [],
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        return FetchUserPlansResponse(
          status: false,
          message: 'Invalid response format',
          data: [],
        );
      }

      return FetchUserPlansResponse.fromJson(decoded);
    } catch (e) {
      return FetchUserPlansResponse(
        status: false,
        message: 'Failed to fetch user plans: $e',
        data: [],
      );
    }
  }
}