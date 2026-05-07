import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:respyr_dietitian/features/coach_sign_in/data/model/dietitian_data_model.dart';


Future<CoachProfileModel?> checkDietitianProfile({required String email}) async {
  final url = Uri.parse("https://humorstech.com/dietitian/api/app/get_dietitian.php");

  try {
    final res = await http
        .post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email.trim()}),
    )
        .timeout(const Duration(seconds: 15));

    if (res.statusCode != 200 && res.statusCode != 404) return null;

    final body = res.body.trim();
    if (body.isEmpty) return null;

    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) return null;

    if (decoded["success"] != true) return null;

    final data = decoded["data"];
    if (data is! Map<String, dynamic>) return null;

    return CoachProfileModel.fromJson(data);
  } catch (_) {
    return null;
  }
}