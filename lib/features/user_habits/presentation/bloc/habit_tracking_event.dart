// lib/features/user_habits/presentation/bloc/habit_tracking_event.dart

part of 'habit_tracking_bloc.dart';

abstract class HabitTrackingEvent extends Equatable {
  const HabitTrackingEvent();

  @override
  List<Object?> get props => [];
}

/// Initial load
class LoadWeeklyHabits extends HabitTrackingEvent {
  final String profileId;
  final String? date; // optional YYYY-MM-DD

  const LoadWeeklyHabits({required this.profileId, this.date});

  @override
  List<Object?> get props => [profileId, date];
}

/// Pull-to-refresh
class RefreshWeeklyHabits extends HabitTrackingEvent {
  final String profileId;
  final String? date;

  const RefreshWeeklyHabits({required this.profileId, this.date});

  @override
  List<Object?> get props => [profileId, date];
}

/// Retry after error
class RetryLoadWeeklyHabits extends HabitTrackingEvent {
  final String profileId;
  final String? date;

  const RetryLoadWeeklyHabits({required this.profileId, this.date});

  @override
  List<Object?> get props => [profileId, date];
}