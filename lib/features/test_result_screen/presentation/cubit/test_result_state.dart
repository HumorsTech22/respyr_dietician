import 'package:equatable/equatable.dart';
import 'package:respyr_dietitian/features/test_result_screen/data/model/test_result_model.dart';

class TestResultState extends Equatable {
  final bool isLoading;
  final TestResultModel? testResult;
  final String selectedTab;

  const TestResultState({
    this.isLoading = false,
    this.testResult,
    this.selectedTab = 'gut',
  });

  TestResultState copyWith({
    bool? isLoading,
    TestResultModel? testResult,
    String? selectedTab,
  }) {
    return TestResultState(
      isLoading: isLoading ?? this.isLoading,
      testResult: testResult ?? this.testResult,
      selectedTab: selectedTab ?? this.selectedTab,
    );
  }

  @override
  List<Object?> get props => [isLoading, testResult, selectedTab];
}
