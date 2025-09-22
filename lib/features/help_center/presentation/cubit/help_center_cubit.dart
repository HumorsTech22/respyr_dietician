import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietitian/features/help_center/presentation/cubit/help_center_state.dart';

class HelpCenterCubit extends Cubit<HelpCenterState> {
  HelpCenterCubit() : super(HelpCenterInitial());

  void toggleFaq(int index) {
    if (state is HelpCenterLoaded) {
      final currentState = (state as HelpCenterLoaded);
      final expanded = List<bool>.from(currentState.expandedFaqs);
      expanded[index] = !expanded[index];

      emit(currentState.copyWith(expandedFaqs: expanded));
    }
  }

  void selectIssue(String issue) {
    if (state is HelpCenterIssue) {
      final currentState = (state as HelpCenterIssue);
      final issues = List<String>.from(currentState.selectedIssue);

      if (issues.contains(issue)) {
        issues.remove(issue);
      } else {
        issues.add(issue);
      }

      emit(currentState.copyWith(selectedIssue: issues));
    }
  }

  void switchTab(int index) {
    emit(HelpCenterIssue(selectedIssue: [], tabIndex: index));
  }
}
