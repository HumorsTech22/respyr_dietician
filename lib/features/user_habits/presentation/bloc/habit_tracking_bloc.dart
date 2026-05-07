// lib/features/user_habits/presentation/bloc/habit_tracking_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:respyr_dietitian/features/user_habits/data/model/weekly_habit_tracking_model.dart';
import '../../data/exceptions/habit_exceptions.dart';
import '../../data/repositories/habit_tracking_repository.dart';

part 'habit_tracking_event.dart';
part 'habit_tracking_state.dart';

class HabitTrackingBloc extends Bloc<HabitTrackingEvent, HabitTrackingState> {
  final HabitTrackingRepository repository;

  HabitTrackingBloc({required this.repository})
      : super(const HabitTrackingState.initial()) {
    on<LoadWeeklyHabits>(_onLoad);
    on<RefreshWeeklyHabits>(_onRefresh);
    on<RetryLoadWeeklyHabits>(_onRetry);
  }

  Future<void> _onLoad(
      LoadWeeklyHabits event,
      Emitter<HabitTrackingState> emit,
      ) async {
    emit(state.copyWith(
      status: HabitTrackingStatus.loading,
      clearError: true,
    ));
    await _fetch(event.profileId, event.date, emit);
  }

  Future<void> _onRefresh(
      RefreshWeeklyHabits event,
      Emitter<HabitTrackingState> emit,
      ) async {
    // Keep existing data visible while refreshing
    emit(state.copyWith(
      status: HabitTrackingStatus.refreshing,
      clearError: true,
    ));
    await _fetch(event.profileId, event.date, emit);
  }

  Future<void> _onRetry(
      RetryLoadWeeklyHabits event,
      Emitter<HabitTrackingState> emit,
      ) async {
    emit(state.copyWith(
      status: HabitTrackingStatus.loading,
      clearError: true,
    ));
    await _fetch(event.profileId, event.date, emit);
  }

  Future<void> _fetch(
      String profileId,
      String? date,
      Emitter<HabitTrackingState> emit,
      ) async {
    try {
      final response = await repository.getWeeklyTracking(
        profileId: profileId,
        date: date,
      );

      if (!response.isSuccess) {
        emit(state.copyWith(
          status: HabitTrackingStatus.failure,
          errorMessage: response.message ?? 'Failed to load habits',
          errorCode: response.errorCode,
          errorHttpCode: response.httpCode,
        ));
        return;
      }

      if (response.habits.isEmpty) {
        emit(state.copyWith(
          status: HabitTrackingStatus.empty,
          data: response,
          clearError: true,
        ));
        return;
      }

      emit(state.copyWith(
        status: HabitTrackingStatus.success,
        data: response,
        clearError: true,
      ));
    } on AppException catch (e) {
      emit(state.copyWith(
        status: HabitTrackingStatus.failure,
        errorMessage: e.message,
        errorCode: e.code,
        errorHttpCode: e.httpCode,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HabitTrackingStatus.failure,
        errorMessage: 'Something went wrong. Please try again.',
        errorCode: 'UNKNOWN',
      ));
    }
  }

  @override
  Future<void> close() {
    repository.dispose();
    return super.close();
  }
}