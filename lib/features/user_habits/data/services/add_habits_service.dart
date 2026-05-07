import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:respyr_dietitian/core/url-manager/url_manager.dart';

import '../model/add_habits_request_model.dart';
import '../model/add_habits_response_model.dart';

class AddHabitsService {


  Future<AddHabitsResponseModel> addHabits(
      AddHabitsRequestModel request,
      ) async {
    try {
      final response = await http
          .post(
        Uri.parse(UrlManager().addUserHabits),
        headers: const {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(request.toJson()),
      )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          return AddHabitsResponseModel.fromJson(decoded);
        } else {
          return const AddHabitsResponseModel(
            status: false,
            message: "Invalid server response format",
          );
        }
      } else {
        return AddHabitsResponseModel(
          status: false,
          message: "Server error: ${response.statusCode}",
        );
      }
    } on TimeoutException {
      return const AddHabitsResponseModel(
        status: false,
        message: "Request timed out. Please try again.",
      );
    } on SocketException {
      return const AddHabitsResponseModel(
        status: false,
        message: "No internet connection.",
      );
    } on FormatException {
      return const AddHabitsResponseModel(
        status: false,
        message: "Invalid response received from server.",
      );
    } catch (e) {
      return AddHabitsResponseModel(
        status: false,
        message: "Something went wrong: $e",
      );
    }
  }
}