import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietitian/features/dietitian_result_screen/data/model/dietitian_result_model.dart';
import 'package:respyr_dietitian/features/dietitian_result_screen/data/repository/dietitian_result_repository.dart';
import 'package:respyr_dietitian/features/dietitian_result_screen/presentation/cubit/dietitian_result_state.dart';

class DietitianResultCubit extends Cubit<DietitianResultState> {
  final DietitianResultRepository repository;
  DietitianResultCubit(this.repository) : super(const DietitianResultState());

  static const List<String> _tabs = ['Gut', 'Fat', 'Liver'];

  Future<void> fetchDietitianResult({
    required int acetone,
    required int ethanol,
    required int hydrogen,
    required bool diabetic,
    required String goal,
    required String dietitianId,
    required String profileId,
  }) async {
    emit(state.copyWith(isLoading: true));

    try {
      final result = await repository.fetchResults(
        acetone: acetone,
        ethanol: ethanol,
        hydrogen: hydrogen,
        diabetic: diabetic,
        goal: goal,
        dietitianId: dietitianId,
        profileId: profileId,
      );

      emit(
        state.copyWith(
          isLoading: false,
          dietitianResult: result,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void changeTab(String tab) {
    emit(state.copyWith(selectedTab: tab));
  }

  void nextTab() {
    final currentIndex = _tabs.indexWhere(
      (tab) => tab.toLowerCase() == state.selectedTab.toLowerCase(),
    );
    if (currentIndex < _tabs.length - 1) {
      emit(state.copyWith(selectedTab: _tabs[currentIndex + 1]));
    }
  }

  void previousTab() {
    final currentIndex = _tabs.indexWhere(
      (tab) => tab.toLowerCase() == state.selectedTab.toLowerCase(),
    );
    if (currentIndex > 0) {
      emit(state.copyWith(selectedTab: _tabs[currentIndex - 1]));
    }
  }
}
