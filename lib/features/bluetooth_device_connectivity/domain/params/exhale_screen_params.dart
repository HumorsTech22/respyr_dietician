import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';

class ExhaleScreenParams {
  final ClientProfileModel clientProfileModel;
  final String baseValue;

  ExhaleScreenParams({
    required this.clientProfileModel,
    required this.baseValue,
  });
}
