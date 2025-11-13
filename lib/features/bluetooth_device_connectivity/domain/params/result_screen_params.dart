import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';

class ResultScreenParams {
  final Map<String, dynamic> args;
  final ClientProfileModel clientProfileModel;

  ResultScreenParams({required this.args, required this.clientProfileModel});
}
