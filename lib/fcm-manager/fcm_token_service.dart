import 'dart:io';
import 'package:flutter/foundation.dart';
import "package:http/http.dart" as http show post;
import 'package:firebase_messaging/firebase_messaging.dart';

import '../client-dashboard/extras/device_info_manager.dart';
import '../core/url-manager/url_manager.dart';

class FCMService {
  static Future<void> saveTokenToServer(String userId) async {
    try {
      // 🔥 Get token
      String? token = await FirebaseMessaging.instance.getToken();
      if (token == null) {
        debugPrint("FCM Token is NULL");
        return;
      }


      final deviceId = await DeviceInfoManager().getDeviceId();


      final url = Uri.parse(UrlManager().urlSaveFcmToken);

      final platform = Platform.isAndroid
          ? 'android'
          : Platform.isIOS
          ? 'ios'
          : 'unknown';

      // 🔥 Send to backend
      final response = await http.post(
        url,
        body: {
          'user_id': userId,
          'device_id': deviceId,
          'fcm_token': token,
          'platform': platform,
        },
      );


    } catch (e, s) {
      debugPrint("Error saving FCM token: $e");
      debugPrint("STACK: $s");
    }
  }
}
