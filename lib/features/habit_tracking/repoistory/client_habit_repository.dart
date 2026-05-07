import 'package:respyr_dietitian/features/habit_tracking/data/model/client_habit_status_response_model.dart';

import '../services/client_habit_service.dart';

class ClientHabitRepository {
  final ClientHabitService service;

  ClientHabitRepository(this.service);

  Future<ClientHabitStatusResponse> fetchClientHabits({
    required String profileId,
    required String trackingDate,
  }) {
    return service.fetchClientHabits(
      profileId: profileId,
      trackingDate: trackingDate,
    );
  }
}