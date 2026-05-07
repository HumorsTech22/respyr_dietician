// lib/features/user_habits/data/repositories/habit_tracking_repository.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:respyr_dietitian/features/user_habits/data/model/weekly_habit_tracking_model.dart';
import '../exceptions/habit_exceptions.dart';

class HabitTrackingRepository {
  final http.Client _client;
  final String baseUrl;
  final Duration timeout;

  HabitTrackingRepository({
    http.Client? client,
    required this.baseUrl,
    this.timeout = const Duration(seconds: 20),
  }) : _client = client ?? http.Client();

  /// Fetch weekly habit tracking for a profile.
  /// [profileId] is required (e.g. "profile98")
  /// [date] optional YYYY-MM-DD; defaults to today on the server.
  Future<WeeklyHabitTrackingResponse> getWeeklyTracking({
    required String profileId,
    String? date,
  }) async {
    if (profileId.trim().isEmpty) {
      throw const ClientException('profile_id is required', code: 'MISSING_PROFILE_ID');
    }

    final uri = Uri.parse('https://humorstech.com/dietitian/api/app/weekly_habit_tracking.php');
    final body = {
      'profile_id': profileId.trim(),
      if (date != null && date.trim().isNotEmpty) 'date': date.trim(),
    };

    http.Response response;

    try {
      response = await _client
          .post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      )
          .timeout(timeout);
    } on SocketException {
      throw const NetworkException();
    } on HttpException {
      throw const NetworkException('Network error occurred');
    } on TimeoutException {
      rethrow;
    } on FormatException {
      throw const ParseException('Invalid request format');
    } on http.ClientException catch (e) {
      throw NetworkException('Connection failed: ${e.message}');
    } catch (e) {
      // Catch dart's TimeoutException specifically
      if (e.toString().toLowerCase().contains('timeout')) {
        throw const TimeoutException();
      }
      throw UnknownException('Unexpected error: $e');
    }

    return _handleResponse(response);
  }

  WeeklyHabitTrackingResponse _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final rawBody = response.body;

    // Try to parse JSON regardless of status (the API returns JSON for errors too)
    Map<String, dynamic>? json;
    try {
      if (rawBody.isNotEmpty) {
        final decoded = jsonDecode(rawBody);
        if (decoded is Map<String, dynamic>) {
          json = decoded;
        }
      }
    } catch (_) {
      // not JSON
    }

    // Server returned valid JSON — use server's status/message
    if (json != null) {
      final apiStatus = json['status']?.toString();

      if (apiStatus == 'success' && statusCode >= 200 && statusCode < 300) {
        try {
          return WeeklyHabitTrackingResponse.fromJson(json);
        } catch (e) {
          throw ParseException('Failed to parse response: $e');
        }
      }

      // Error path — extract structured error info
      final message = json['message']?.toString() ?? 'Request failed';
      final code = json['error_code']?.toString();

      if (statusCode == 404 || code == 'PROFILE_NOT_FOUND') {
        throw NotFoundException(message);
      }
      if (statusCode >= 400 && statusCode < 500) {
        throw ClientException(message, code: code, httpCode: statusCode);
      }
      if (statusCode >= 500) {
        throw ServerException(message, statusCode);
      }

      throw UnknownException(message);
    }

    // Non-JSON body
    if (statusCode >= 500) {
      throw ServerException('Server error (HTTP $statusCode)', statusCode);
    }
    if (statusCode >= 400) {
      throw ClientException('Request failed (HTTP $statusCode)', httpCode: statusCode);
    }
    throw const ParseException();
  }

  void dispose() {
    _client.close();
  }
}