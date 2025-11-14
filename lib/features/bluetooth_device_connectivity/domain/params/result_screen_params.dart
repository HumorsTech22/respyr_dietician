import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/model/generating_result_model.dart';

class ResultScreenParams {
  final GeneratingResultModel result;
  final ClientProfileModel clientProfileModel;

  ResultScreenParams({required this.result, required this.clientProfileModel});
}
