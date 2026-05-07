import 'package:equatable/equatable.dart';

abstract class ClientProfileEvent extends Equatable {
  const ClientProfileEvent();

  @override
  List<Object?> get props => [];
}

class FetchClientsByDietician extends ClientProfileEvent {
  final String dieticianId;

  const FetchClientsByDietician(this.dieticianId);

  @override
  List<Object?> get props => [dieticianId];
}