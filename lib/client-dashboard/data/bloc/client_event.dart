abstract class ClientEvent {}

class FetchClientProfile extends ClientEvent {
  final String dietitianId;
  final String profileId;
  FetchClientProfile(this.dietitianId, this.profileId);
}