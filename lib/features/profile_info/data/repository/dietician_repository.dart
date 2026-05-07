import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:respyr_dietitian/features/profile_info/data/model/dietician_detail_model.dart';

class DietitianRepository {
  Future<DietitianDetailModel?> fetchDietitian(String identifier) async {
    const String baseUrl =
        "https://humorstech.com/humors_app/app_final/dieticianapp/api/get_dietician.php";

    try {
      final response = await http
          .post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {"identifier": identifier},
      )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        throw Exception("Unable to reach server. Please try again.");
      }

      final jsonResponse = json.decode(response.body);

      if (jsonResponse['success'] == true) {
        return DietitianDetailModel.fromJson(jsonResponse);
      }

      throw Exception(
        jsonResponse['message']?.toString() ?? "Dietitian details not found.",
      );
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