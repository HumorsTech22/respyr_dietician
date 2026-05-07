import 'dart:convert';
import 'package:http/http.dart' as http;

import '../data/model/activate_coupon_data.dart';

class ActivateCouponService {
  static const String _url =
      "https://humorstech.com/dietitian/api/app/insert_client_plan.php";

  Future<ActivateCouponResponse> activateCoupon({
    required String profileId,
    required String couponCode,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "profile_id": profileId,
          "coupon_code": couponCode,
        }),
      );

      if (response.body.isEmpty) {
        return ActivateCouponResponse(
          status: false,
          message: "Empty response from server",
          data: null,
        );
      }

      final Map<String, dynamic> jsonMap =
      jsonDecode(response.body) as Map<String, dynamic>;

      return ActivateCouponResponse.fromJson(jsonMap);
    } catch (e) {
      return ActivateCouponResponse(
        status: false,
        message: "Something went wrong: $e",
        data: null,
      );
    }
  }
}

