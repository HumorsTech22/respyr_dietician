abstract class WeeklyTabEvent {}

class FetchWeeklyTabs extends WeeklyTabEvent {
  final String profileId;
  final String dietitianId;

  FetchWeeklyTabs({
    required this.profileId,
    required this.dietitianId,
  });
}