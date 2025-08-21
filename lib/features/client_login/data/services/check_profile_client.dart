import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../client-dashboard/model/client_profile_model.dart';


Future<ClientProfileModel?> checkClientProfile(String email, String phone) async {
  final url = Uri.parse("https://humorstech.com/humors_app/app_final/dieticianapp/api/check_client_profile.php");

  final response = await http.post(url, body: {
    'phone_no': phone,
    'email': email,
  });

  final jsonBody = json.decode(response.body);

  if (response.statusCode == 200 && jsonBody['success'] == true) {
    return ClientProfileModel.fromJson(jsonBody['data']);
  } else {
    return null;
  }
}
