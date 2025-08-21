import 'dart:convert';
import 'package:http/http.dart' as http show post;

Future<Map<String, dynamic>> sendOtpToEmail(String email, String otp) async {
  const String apiUrl = "https://humorstech.com/humors_app/app_final/dieticianapp/api/send_email_otp.php";

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      body: {
        'email': email,
        'otp': otp,
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      if (jsonData['success'] == true) {
      } else {
      }

      return jsonData;
    } else {
      throw Exception("Failed with status code: ${response.statusCode}");
    }
  } catch (e) {
    return {
      "success": false,
      "message": "$e",
    };
  }
}
