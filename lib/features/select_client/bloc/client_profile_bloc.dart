import 'package:flutter_bloc/flutter_bloc.dart';
import 'client_profile_event.dart';
import 'client_profile_state.dart';
import '../services/client_profile_service.dart';

class ClientProfileBloc
    extends Bloc<ClientProfileEvent, ClientProfileState> {
  final ClientProfileService service;

  ClientProfileBloc({required this.service})
      : super(ClientProfileInitial()) {
    on<FetchClientsByDietician>(_fetchClients);
  }

  Future<void> _fetchClients(
      FetchClientsByDietician event,
      Emitter<ClientProfileState> emit,
      ) async {
    emit(ClientProfileLoading());

    try {
      final clients =
      await service.getClientsByDietician(event.dieticianId);

      emit(ClientProfileLoaded(clients));
    } catch (e) {
      emit(ClientProfileError(e.toString()));
    }
  }
}