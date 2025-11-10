import 'package:equatable/equatable.dart';
import 'package:respyr_dietitian/features/dietitian_result_screen/data/model/dietitian_result_model.dart';

class DietitianResultState extends Equatable {
  final bool isLoading;
  final DietitianResultModel? dietitianResult;
  final String selectedTab;
  final String? errorMessage;

  const DietitianResultState({
    this.isLoading = false,
    this.dietitianResult,
    this.selectedTab = 'gut',
    this.errorMessage,
  });

  DietitianResultState copyWith({
    bool? isLoading,
    DietitianResultModel? dietitianResult,
    String? selectedTab,
    String? errorMessage,
  }) {
    return DietitianResultState(
      isLoading: isLoading ?? this.isLoading,
      dietitianResult: dietitianResult ?? this.dietitianResult,
      selectedTab: selectedTab ?? this.selectedTab,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    dietitianResult,
    selectedTab,
    errorMessage,
  ];
}
