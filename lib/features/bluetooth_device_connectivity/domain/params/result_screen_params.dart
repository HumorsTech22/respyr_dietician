import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/common/features_allow/data/model/features_allow_model.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/model/generating_result_model.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/model/respyr_unified_response.dart';

import '../../data/model/test_result_data_model_v2.dart';

class ResultScreenParams {
  final GeneratingResultModel result;
  final ClientProfileModel clientProfileModel;

  ResultScreenParams({required this.result, required this.clientProfileModel});
}

class ResultScreenParamsNew {
  final RespyrUnifiedResponse respyrUnifiedResponse;
  final ClientProfileModel clientProfileModel;
  final FeaturesAllowData featuresAllowData;
  ResultScreenParamsNew({required this.clientProfileModel, required this.featuresAllowData, required this.respyrUnifiedResponse});
}

