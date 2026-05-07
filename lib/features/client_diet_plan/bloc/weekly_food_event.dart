abstract class WeeklyFoodEvent {}

class FetchWeeklyFood extends WeeklyFoodEvent {
  final String profileId;
  final String dietitianId;
  final String weekStartDate;
  final String weekEndDate;

  FetchWeeklyFood({
    required this.profileId,
    required this.dietitianId,
    required this.weekStartDate,
    required this.weekEndDate,
  });
}