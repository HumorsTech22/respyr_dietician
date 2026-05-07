import 'package:equatable/equatable.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';

abstract class ClientProfileState extends Equatable {
  const ClientProfileState();

  @override
  List<Object?> get props => [];
}

class ClientProfileInitial extends ClientProfileState {}

class ClientProfileLoading extends ClientProfileState {}

class ClientProfileLoaded extends ClientProfileState {
  final List<ClientProfileModel> clients;

  const ClientProfileLoaded(this.clients);

  @override
  List<Object?> get props => [clients];
}

class ClientProfileError extends ClientProfileState {
  final String message;

  const ClientProfileError(this.message);

  @override
  List<Object?> get props => [message];
}