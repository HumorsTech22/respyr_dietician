import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:respyr_dietitian/features/account_delete/data/model/delete_account_response.dart';


class DeleteAccountService {
  DeleteAccountService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  // Change this to your real API URL
  static const String _deleteAccountUrl =
      'https://humorstech.com/dietitian/api/app/account_delete.php';

  Future<DeleteAccountResponse> deleteAccount({
    required String profileId,
  }) async {
    final uri = Uri.parse(_deleteAccountUrl);

    try {
      final response = await _client
          .post(
        uri,
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'profile_id': profileId,
        }),
      )
          .timeout(const Duration(seconds: 20));

      final Map<String, dynamic> jsonBody = _decodeJson(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return DeleteAccountResponse.fromJson(jsonBody);
      }

      final message = (jsonBody['message'] ?? 'Failed to delete account').toString();
      throw DeleteAccountException(
        message: message,
        statusCode: response.statusCode,
      );
    } on SocketException {
      throw const DeleteAccountException(
        message: 'No internet connection.',
      );
    } on HttpException {
      throw const DeleteAccountException(
        message: 'Unable to reach server.',
      );
    } on FormatException {
      throw const DeleteAccountException(
        message: 'Invalid server response.',
      );
    } on DeleteAccountException {
      rethrow;
    } catch (e) {
      throw DeleteAccountException(
        message: 'Unexpected error: $e',
      );
    }
  }

  Map<String, dynamic> _decodeJson(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw const FormatException('Response is not a JSON object');
  }

  void dispose() {
    _client.close();
  }
}

class DeleteAccountException implements Exception {
  final String message;
  final int? statusCode;

  const DeleteAccountException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() {
    if (statusCode != null) {
      return 'DeleteAccountException($statusCode): $message';
    }
    return 'DeleteAccountException: $message';
  }
}