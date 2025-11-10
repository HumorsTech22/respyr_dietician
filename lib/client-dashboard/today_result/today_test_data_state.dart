import 'package:equatable/equatable.dart';

import '../../features/test_history/test_history_by_date/data/models/test_data_record.dart';

enum TestDataStatus { initial, loading, success, empty, failure }

class TestDataState extends Equatable {
  final TestDataStatus status;
  final List<TestDataRecord> records;
  final String? errorMessage;

  const TestDataState({
    this.status = TestDataStatus.initial,
    this.records = const [],
    this.errorMessage,
  });

  TestDataState copyWith({
    TestDataStatus? status,
    List<TestDataRecord>? records,
    String? errorMessage,
  }) {
    return TestDataState(
      status: status ?? this.status,
      records: records ?? this.records,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, records, errorMessage];
}
