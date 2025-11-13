import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';

class GeneratingResultParams {
  final double maxPressure;
  final double bestPressure;
  final int blowDuration;
  final List<double> blowValuesList;
  final ClientProfileModel clientProfileModel;

  GeneratingResultParams({
    required this.maxPressure,
    required this.bestPressure,
    required this.blowDuration,
    required this.blowValuesList,
    required this.clientProfileModel,
  });
}
