import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietitian/features/client_diet_plan/data/services/weekly_tab_service.dart';
import 'weekly_tab_event.dart';
import 'weekly_tab_state.dart';

class WeeklyTabBloc extends Bloc<WeeklyTabEvent, WeeklyTabState> {
  WeeklyTabBloc() : super(WeeklyTabInitial()) {
    on<FetchWeeklyTabs>(_fetchWeeklyTabs);
  }

  Future<void> _fetchWeeklyTabs(
      FetchWeeklyTabs event,
      Emitter<WeeklyTabState> emit,
      ) async {
    emit(WeeklyTabLoading());

    try {
      final response = await WeeklyTabService.fetchWeeklyTabs(
        profileId: event.profileId,
        dietitianId: event.dietitianId,
      );

      if (response.status) {
        emit(WeeklyTabLoaded(response));
      } else {
        emit(WeeklyTabError(response.message));
      }
    } catch (e) {
      emit(WeeklyTabError(e.toString()));
    }
  }
}