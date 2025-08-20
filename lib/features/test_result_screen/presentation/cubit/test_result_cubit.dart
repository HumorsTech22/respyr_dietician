import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietitian/features/test_result_screen/data/model/test_result_model.dart';
import 'package:respyr_dietitian/features/test_result_screen/presentation/cubit/test_result_state.dart';

class TestResultCubit extends Cubit<TestResultState> {
  TestResultCubit() : super(const TestResultState());

  static const List<String> _tabs = ['Gut', 'Liver', 'Fat'];

  void loadMockData() {
    final testResult = TestResultModel(
      dttm: DateTime(2025, 7, 5, 12, 30).millisecondsSinceEpoch,
      gutAbsorptiveScore: 97,
      gutFermentativeScore: 3,
      fatMetabolismScore: 70,
      fatGlucoseMetabolismScore: 55,
      liverHepaticScore: 82,
      liverDetoxScore: 78,
    );

    emit(state.copyWith(testResult: testResult));
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
