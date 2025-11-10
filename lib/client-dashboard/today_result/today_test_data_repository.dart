import 'package:intl/intl.dart';
import 'package:respyr_dietitian/client-dashboard/today_result/today_test_data_api_service.dart';

import '../../features/test_history/test_history_by_date/data/models/test_data_record.dart';


class TodayTestDataRepository {
  final TodayTestDataApiService api;
  TodayTestDataRepository(this.api);

  /// Fetch records for a specific day (IST).
  /// If [date] is null, the API should return “today” (per your PHP).
  Future<List<TestDataRecord>> fetchDay({
    required String profileId,
    required String dietitianId,
    DateTime? date, // pass when you want a specific day
  }) async {
    String? day;
    if (date != null) {
      // format YYYY-MM-DD
      day = DateFormat('yyyy-MM-dd').format(date);
    }

    final jsonMap = await api.fetchForDay(profileId: profileId, dateYYYYMMDD: day!, dietitianId: dietitianId);
    final data = (jsonMap['data'] as List?) ?? [];

    // If data is empty, you might still want to return a dummy record
    // to indicate "no test taken". Your UI can decide based on count.
    final isTakenTest = data.isNotEmpty;

    return data.map<TestDataRecord>((e) {
      return TestDataRecord.fromJson(e as Map<String, dynamic>, isTakenTest);
    }).toList();
  }
}
