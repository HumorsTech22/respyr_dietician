import 'package:equatable/equatable.dart';
import 'package:respyr_dietitian/features/dietictian_result_screen/data/model/dietitian_result_model.dart';

class DietitianResultState extends Equatable {
  final bool isLoading;
  final DietitianResultModel? dietitianResult;
  final String selectedTab;

  const DietitianResultState({
    this.isLoading = false,
    this.dietitianResult,
    this.selectedTab = 'gut',
  });

  DietitianResultState copyWith({
    bool? isLoading,
    DietitianResultModel? testResult,
    String? selectedTab,
  }) {
    return DietitianResultState(
      isLoading: isLoading ?? this.isLoading,
      dietitianResult: testResult ?? this.dietitianResult,
      selectedTab: selectedTab ?? this.selectedTab,
    );
  }

  @override
  List<Object?> get props => [isLoading, dietitianResult, selectedTab];
}
