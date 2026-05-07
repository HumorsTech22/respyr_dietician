import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/model/generating_result_model.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/model/respyr_unified_response.dart';

import '../model/test_result_data_model_v2.dart';

class GeneratingResultRepository {
  // static const String _url =
  //     'https://humorstech.com/dietitian/api/app/daily_result_new_v2.php';
  static const String _url = 'https://humorstech.com/dietitian/api/app/dummy_result.php';

  static const Duration _timeout = Duration(seconds: 45);
  static const int _maxAttempts = 3;

  Future<GeneratingResultModel> fetchResults({
    required double acetone,
    required double ethanol,
    required double hydrogen,
    required bool diabetic,
    required String goal,
    int debug = 1,
    required String dietitianId,
    required String profileId,
    required String dietPlanId,
    required double minRange,
    required double maxRange,
  }) async {
    final url = Uri.parse(_url);

    final body = {
      "acetone": acetone,
      "ethanol": ethanol,
      "hydrogen": hydrogen,
      "diabetic": diabetic,
      "goal": "muscle_gain",
      "debug": debug,
      "dietitian_id": dietitianId,
      "profile_id": profileId,
      "diet_plan_id": dietPlanId,
      "min_range": minRange,
      "max_range": maxRange,
    };

    try {
      final response = await _postJsonWithRetry(
        url: url,
        body: body,
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (data['success'] == true) {
        return GeneratingResultModel.fromJson(data);
      } else {
        throw Exception(
          data['message']?.toString() ?? "Something went wrong from server",
        );
      }
    } on SocketException {
      throw Exception("No internet connection. Please check your network.");
    } on TimeoutException {
      throw Exception("Internet is slow. Request timed out, please try again.");
    } on FormatException {
      throw Exception("Invalid response from server.");
    } catch (e) {
      throw Exception(
        e.toString().replaceFirst("Exception: ", ""),
      );
    }
  }



  Future<RespyrUnifiedResponse> fetchResultsNew({
    required double acetone,
    required double ethanol,
    required double hydrogen,
    required bool diabetic,
    required String goal,
    int debug = 1,
    required String dietitianId,
    required String profileId,
    required String dietPlanId,
    required double minRange,
    required double maxRange,
    required ClientProfileModel client,
    required String deviceId,
    required String age,
    required String activity,
  }) async {
    final url = Uri.parse(_url);

    final body = {
      "acetone": acetone,
      "ethanol": ethanol,
      "hydrogen": hydrogen,
      "diabetic": diabetic,
      "goal": goal,
      "debug": debug,
      "dietitian_id": dietitianId,
      "profile_id": profileId,
      "diet_plan_id": dietPlanId,
      "min_range": minRange,
      "max_range": maxRange,
      "height_cm": client.height,
      "weight_kg": client.weight,
      "sex": client.gender.toLowerCase(),
      "activity": activity,
      "device_id": profileId,
      "age": age,
    };

    try {
      final response = await _postJsonWithRetry(
        url: url,
        body: body,
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (data['success'] != true) {
        throw Exception(
          data['message']?.toString() ?? "Something went wrong from server",
        );
      }

      final Map<String, dynamic> respyrJson =
      data['respyr_response'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(data['respyr_response'])
          : <String, dynamic>{};

      respyrJson['date_time'] = (data['date_time'] ?? '').toString();

      return RespyrUnifiedResponse.fromJson(respyrJson);
    } on SocketException {
      throw Exception("No internet connection. Please check your network.");
    } on TimeoutException {
      throw Exception("Internet is slow. Request timed out, please try again.");
    } on FormatException {
      throw Exception("Invalid response from server.");
    } catch (e) {
      throw Exception(
        e.toString().replaceFirst("Exception: ", ""),
      );
    }
  }


  Future<http.Response> _postJsonWithRetry({
    required Uri url,
    required Map<String, dynamic> body,
  }) async {
    Object? lastError;
    http.Response? lastResponse;

    for (int attempt = 1; attempt <= _maxAttempts; attempt++) {
      try {
        final response = await http
            .post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(body),
        )
            .timeout(_timeout);

        lastResponse = response;

        if (response.statusCode == 200) {
          return response;
        }

        if (response.statusCode >= 500 && attempt < _maxAttempts) {
          await Future.delayed(Duration(seconds: attempt * 2));
          continue;
        }

        if (response.statusCode >= 500) {
          throw Exception("Server is busy. Please try again.");
        } else {
          throw Exception("Network error: ${response.statusCode}");
        }
      } on SocketException catch (e) {
        lastError = e;
        if (attempt < _maxAttempts) {
          await Future.delayed(Duration(seconds: attempt * 2));
          continue;
        }
      } on TimeoutException catch (e) {
        lastError = e;
        if (attempt < _maxAttempts) {
          await Future.delayed(Duration(seconds: attempt * 2));
          continue;
        }
      }
    }

    if (lastError != null) {
      throw lastError;
    }

    if (lastResponse != null) {
      if (lastResponse!.statusCode >= 500) {
        throw Exception("Server is busy. Please try again.");
      } else {
        throw Exception("Network error: ${lastResponse!.statusCode}");
      }
    }

    throw Exception("Unable to connect to server. Please try again.");
  }
}