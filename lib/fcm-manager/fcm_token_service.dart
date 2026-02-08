import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http show post;
import 'package:permission_handler/permission_handler.dart';

import '../client-dashboard/extras/device_info_manager.dart';
import '../core/url-manager/url_manager.dart';

class FCMService {
  static Future<void> saveTokenToServer(String userId) async {
    try {
      // Ensure APNs Token is available first
      String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      if (apnsToken == null) {
        debugPrint("APNs Token not received yet");
        return; // Ensure the APNs token is available before calling getToken
      }

      // 🔥 Get FCM token
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

      // Handle HTTP response
      if (response.statusCode == 200) {
        debugPrint("FCM Token saved successfully");
      } else {
        debugPrint("Failed to save FCM token. Status code: ${response.statusCode}");
        debugPrint("Response body: ${response.body}");
      }
    } catch (e, s) {
      debugPrint("Error saving FCM token: $e");
      debugPrint("STACK: $s");
    }
  }
}
