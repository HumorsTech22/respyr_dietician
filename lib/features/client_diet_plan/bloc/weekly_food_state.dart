
import 'package:respyr_dietitian/features/client_diet_plan/data/model/weekly_food_model.dart';

abstract class WeeklyFoodState {}

class WeeklyFoodInitial extends WeeklyFoodState {}

class WeeklyFoodLoading extends WeeklyFoodState {}

class WeeklyFoodLoaded extends WeeklyFoodState {
  final WeeklyFoodResponse response;

  WeeklyFoodLoaded(this.response);
}

class WeeklyFoodError extends WeeklyFoodState {
  final String message;

  WeeklyFoodError(this.message);
}