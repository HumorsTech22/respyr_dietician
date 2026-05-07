import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class DashboardOperationRepository {
  final String baseUrl;

  DashboardOperationRepository({
    this.baseUrl = 'https://humorstech.com/dietitian/api/app/',
  });

  Future<void> insertWeightLog(
      String profileId,
      double weightKg,
      String loggedBy,
      String loggedById,
      String? notes,
      ) async {
    try {
      final uri = Uri.parse('${baseUrl}insert_weight_log.php');

      final response = await http
          .post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'profile_id': profileId,
          'weight_kg': weightKg,
          'logged_by': loggedBy,
          'logged_by_id': loggedById,
          "target_weight": 0,
          "weight_change_type": "weight_loss",
          'notes': notes,
        }),
      )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        throw Exception('Server is not responding. Please try again.');
      }

      final Map<String, dynamic> jsonRes = jsonDecode(response.body);

      if (jsonRes['status'] != true) {
        throw Exception(jsonRes['message']?.toString() ?? 'Insert failed');
      }
    } on SocketException {
      throw Exception("No internet connection. Please check your network.");
    } on HttpException {
      throw Exception("Unable to reach server. Please try again.");
    } on FormatException {
      throw Exception("Invalid server response.");
    } on TimeoutException {
      throw Exception("Request timed out. Internet may be slow.");
    } catch (e) {
      throw Exception(e.toString().replaceFirst("Exception: ", ""));
    }
  }
}