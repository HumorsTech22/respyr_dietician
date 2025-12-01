// lib/features/tracking/weight_tracking/data/repository/weight_log_repository.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/weight_log_model.dart';

class WeightLogRepository {
  final String baseUrl;

  WeightLogRepository({
    this.baseUrl = 'https://humorstech.com/dietitian/api/app/',
  });

  Future<List<WeightLogModel>> fetchWeightLogs(String profileId) async {
    final uri = Uri.parse('${baseUrl}get_weight_logs.php');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'profile_id': profileId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Request failed: ${response.statusCode} ${response.reasonPhrase}');
    }

    final Map<String, dynamic> jsonRes = jsonDecode(response.body);

    if (jsonRes['status'] != true) {
      throw Exception(jsonRes['message']?.toString() ?? 'Unknown error');
    }

    final List data = jsonRes['data'] as List;
    return data.map((e) => WeightLogModel.fromJson(e)).toList();
  }
}
