import 'package:respyr_dietitian/client-dashboard/model/test_log_model.dart';

class TestLogStatus {
  final bool success;
  final String message;
  final bool hasLog;
  final TestLog? log;
  const TestLogStatus({
    required this.success,
    required this.message,
    required this.hasLog,
    this.log,
  });
}