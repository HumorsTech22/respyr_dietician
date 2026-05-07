import 'package:respyr_dietitian/features/client_diet_plan/data/model/weekly_tab_model.dart';


abstract class WeeklyTabState {}

class WeeklyTabInitial extends WeeklyTabState {}

class WeeklyTabLoading extends WeeklyTabState {}

class WeeklyTabLoaded extends WeeklyTabState {
  final WeeklyTabResponse response;

  WeeklyTabLoaded(this.response);
}

class WeeklyTabError extends WeeklyTabState {
  final String message;

  WeeklyTabError(this.message);
}