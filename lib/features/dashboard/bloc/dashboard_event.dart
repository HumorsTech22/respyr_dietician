import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';

abstract class DashboardEvent {}

class DashboardInitialized extends DashboardEvent {
  final ClientProfileModel clientProfileModel;
  DashboardInitialized(this.clientProfileModel);
}

class RefreshDashboard extends DashboardEvent {
  final ClientProfileModel clientProfileModel;
  RefreshDashboard(this.clientProfileModel);
}

class RequestDietitianLink extends DashboardEvent {
  final ClientProfileModel clientProfileModel;
  final String dietitianId; // RespyrD02 etc.

  RequestDietitianLink({
    required this.clientProfileModel,
    required this.dietitianId,
  });
}

/// 🔥 Just checks status via API, does NOT reload dashboard
class CheckDietitianLinkStatus extends DashboardEvent {
  final String profileId;
  CheckDietitianLinkStatus(this.profileId);
}
