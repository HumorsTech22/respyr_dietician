import 'dart:io'; // add this import
import 'package:flutter/foundation.dart';
import "package:http/http.dart" as http show post;
import 'package:firebase_messaging/firebase_messaging.dart';

import '../core/url-manager/url_manager.dart';


class FCMService {
  static Future<void> saveTokenToServer(String userId, String deviceId) async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token == null) {
        return;
      }

      final url = Uri.parse(UrlManager().urlSaveFcmToken);

      final platform = Platform.isAndroid
          ? 'android'
          : Platform.isIOS
          ? 'ios'
          : 'unknown';

      await http.post(
        url,
        body: {
          'user_id': userId,
          'device_id': deviceId,
          'fcm_token': token,
          'platform': platform,
        },
      );

    } catch (e) {
      if (kDebugMode) {
        print("Error saving FCM token: $e");
      }
    }
  }
}
