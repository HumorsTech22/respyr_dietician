import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietitian/features/client_diet_plan/data/services/weekly_food_service.dart';
import 'weekly_food_event.dart';
import 'weekly_food_state.dart';

class WeeklyFoodBloc extends Bloc<WeeklyFoodEvent, WeeklyFoodState> {
  WeeklyFoodBloc() : super(WeeklyFoodInitial()) {
    on<FetchWeeklyFood>(_fetchWeeklyFood);
  }

  Future<void> _fetchWeeklyFood(
      FetchWeeklyFood event,
      Emitter<WeeklyFoodState> emit,
      ) async {
    emit(WeeklyFoodLoading());

    try {
      final response = await WeeklyFoodService.fetchWeeklyFood(
        profileId: event.profileId,
        dietitianId: event.dietitianId,
        weekStartDate: event.weekStartDate,
        weekEndDate: event.weekEndDate,
      );

      if (response.status) {
        emit(WeeklyFoodLoaded(response));
      } else {
        emit(WeeklyFoodError(response.message));
      }
    } catch (e) {
      emit(WeeklyFoodError(e.toString()));
    }
  }
}