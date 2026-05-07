import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:respyr_dietitian/features/dashboard/qua_dashboard/data/models/macro_summary_model.dart';

class MacroSummaryService {
  static const String _baseUrl =
      'https://humorstech.com/dietitian/api/app/get_macro_summary_by_date.php';

  Future<MacroSummaryResponse> fetchMacroSummary({
    required String profileId,
    required String date,
  }) async {
    final uri = Uri.parse(_baseUrl);

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'profile_id': profileId,
        'date': date,
      }),
    );

    final decoded = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return MacroSummaryResponse.fromJson(decoded);
    } else {
      throw Exception(decoded['message'] ?? 'Something went wrong');
    }
  }
}