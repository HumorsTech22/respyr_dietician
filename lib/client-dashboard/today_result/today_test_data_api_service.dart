import 'dart:convert';
import 'package:http/http.dart' as http;

class TodayTestDataApiService {
  final String baseUrl;
  TodayTestDataApiService({
    this.baseUrl = "https://humorstech.com/humors_app/app_final/dieticianapp/api",
  });


  Future<Map<String, dynamic>> fetchForDay({
    required String profileId,
    String? dateYYYYMMDD,
  }) async {
    final uri = Uri.parse("$baseUrl/get_todays_result.php");

    final body = <String, String>{
      "profile_id": profileId,
      if (dateYYYYMMDD != null && dateYYYYMMDD.isNotEmpty) "date": dateYYYYMMDD,
    };

    final resp = await http.post(
      uri,
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: body,
    );

    if (resp.statusCode != 200) {
      throw Exception("HTTP ${resp.statusCode}: ${resp.reasonPhrase}");
    }
    final decoded = json.decode(resp.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception("Invalid JSON structure");
    }
    if (decoded['success'] != true) {
      throw Exception(decoded['error']?.toString() ?? "API returned success=false");
    }
    return decoded;
  }
}
