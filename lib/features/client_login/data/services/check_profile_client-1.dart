import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

import '../../../../client-dashboard/data/model/client_profile_model.dart';
import '../../../../core/url-manager/url_manager.dart';

Future<ClientProfileModel?> checkClientProfile({
  required String userEmail,
}) async {
  final url = Uri.parse(UrlManager().urlUserCheckProfile);

  try {
    final response = await http
        .post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": userEmail.trim()}),
    )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) return null;

    final body = response.body.trim();
    if (body.isEmpty) return null;

    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) return null;

    if (decoded['success'] != true) return null;

    final token = decoded['token'];
    if (token is! String || token.isEmpty) return null;

    if (JwtDecoder.isExpired(token)) return null;

    final payload = JwtDecoder.decode(token);
    final profile = payload['profile'];

    if (profile is! Map<String, dynamic>) return null;

    return ClientProfileModel.fromJson(profile);
  } catch (_) {
    return null;
  }
}