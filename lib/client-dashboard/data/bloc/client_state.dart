import '../model/client_profile_model.dart';

abstract class ClientState {}

class ClientInitial extends ClientState {}

class ClientLoading extends ClientState {}

class ClientLoaded extends ClientState {
  final ClientProfileModel client;
  ClientLoaded(this.client);
}

class ClientError extends ClientState {
  final String message;
  ClientError(this.message);
}
