import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/client_repository.dart';
import 'client_event.dart';
import 'client_state.dart';

class ClientBloc extends Bloc<ClientEvent, ClientState> {
  final ClientRepository repository;

  ClientBloc(this.repository) : super(ClientInitial()) {
    on<FetchClientProfile>((event, emit) async {
      emit(ClientLoading());
      try {
        final clients = await repository.fetchClients(event.dietitianId, event.profileId);

        if (clients.isNotEmpty) {
          emit(ClientLoaded(clients.first));
        } else {
          emit(ClientError("No profile found"));
        }
      } catch (e) {
        emit(ClientError(e.toString()));
      }
    });
  }
}
