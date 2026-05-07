// lib/features/user_habits/presentation/bloc/habit_tracking_state.dart

part of 'habit_tracking_bloc.dart';

enum HabitTrackingStatus { initial, loading, refreshing, success, empty, failure }

class HabitTrackingState extends Equatable {
  final HabitTrackingStatus status;
  final WeeklyHabitTrackingResponse? data;
  final String? errorMessage;
  final String? errorCode;
  final int? errorHttpCode;

  const HabitTrackingState({
    this.status = HabitTrackingStatus.initial,
    this.data,
    this.errorMessage,
    this.errorCode,
    this.errorHttpCode,
  });

  const HabitTrackingState.initial() : this();

  HabitTrackingState copyWith({
    HabitTrackingStatus? status,
    WeeklyHabitTrackingResponse? data,
    String? errorMessage,
    String? errorCode,
    int? errorHttpCode,
    bool clearError = false,
  }) {
    return HabitTrackingState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      errorCode: clearError ? null : (errorCode ?? this.errorCode),
      errorHttpCode: clearError ? null : (errorHttpCode ?? this.errorHttpCode),
    );
  }

  // Convenience getters
  bool get isLoading => status == HabitTrackingStatus.loading;
  bool get isRefreshing => status == HabitTrackingStatus.refreshing;
  bool get isSuccess => status == HabitTrackingStatus.success;
  bool get isEmpty => status == HabitTrackingStatus.empty;
  bool get isFailure => status == HabitTrackingStatus.failure;
  bool get hasData => data != null && (data?.habits.isNotEmpty ?? false);

  List<HabitItem> get habits => data?.habits ?? const [];
  WeekSummary? get weekSummary => data?.weekSummary;

  @override
  List<Object?> get props =>
      [status, data, errorMessage, errorCode, errorHttpCode];
}