import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/features_allow_model.dart';

class FeaturesAllowService {

  FeaturesAllowService();

  Future<FeaturesAllowResponse> fetchFeaturesAllow({
    required String dieticianId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("https://humorstech.com/dietitian/api/app/get_features_allow.php"),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "dietician_id": dieticianId,
        }),
      );

      print("response" + response.body);

      if (response.statusCode == 200) {
        final jsonMap = jsonDecode(response.body);

        if (jsonMap["status"] == true && jsonMap["data"] != null) {
          return FeaturesAllowResponse(
            success: true,
            failReason: null,
            data: FeaturesAllowData.fromJson(jsonMap["data"]),
          );
        } else {
          return FeaturesAllowResponse(
            success: false,
            failReason: jsonMap["message"] ?? "API returned failure",
            data: _defaultFeatures(),
          );
        }
      } else {
        return FeaturesAllowResponse(
          success: false,
          failReason: "Server error ${response.statusCode}",
          data: _defaultFeatures(),
        );
      }
    } catch (e) {
      return FeaturesAllowResponse(
        success: false,
        failReason: "Exception: $e",
        data: _defaultFeatures(),
      );
    }
  }

  /// default all TRUE
  FeaturesAllowData _defaultFeatures() {
    return FeaturesAllowData(
      id: 0,
      dieticianId: "",
      testAllow: true,
      practiceTestAllow: true,
      detailedScores: true, multipleReading: true,
    );
  }
}