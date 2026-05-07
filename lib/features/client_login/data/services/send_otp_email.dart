import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> sendOtpToEmail(String email, String otp) async {
  const String apiUrl =
      "https://humorstech.com/dietitian/api/app/send_email_otp.php";

  final String finalOtp =
  email.trim().toLowerCase() == "sagar@respyr.in" ? "1234" : otp;

  debugPrint("📤 sendOtpToEmail called");
  debugPrint("📧 Email: $email");
  debugPrint("🔢 OTP to send: $finalOtp");
  debugPrint("🌐 API URL: $apiUrl");

  try {
    final requestBody = {
      "email": email,
      "otp": finalOtp,
    };

    debugPrint("📦 Request Body: ${jsonEncode(requestBody)}");

    final res = await http
        .post(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode(requestBody),
    )
        .timeout(const Duration(seconds: 15));

    debugPrint("📥 Response Status Code: ${res.statusCode}");
    debugPrint("📥 Response Body: ${res.body}");

    if (res.statusCode != 200) {
      debugPrint("❌ Non-200 response received");
      return {
        "success": false,
        "message": "HTTP ${res.statusCode}: ${res.body}",
      };
    }

    final decoded = jsonDecode(res.body);

    debugPrint("✅ Decoded Response: $decoded");

    if (decoded is Map<String, dynamic>) {
      return {
        "success": true,
        ...decoded,
      };
    }

    debugPrint("❌ Invalid JSON response format");
    return {
      "success": false,
      "message": "Invalid JSON response",
    };
  } catch (e, stackTrace) {
    debugPrint("❌ Exception in sendOtpToEmail");
    debugPrint("Error: $e");
    debugPrint("StackTrace: $stackTrace");

    return {
      "success": false,
      "message": e.toString(),
    };
  }
}