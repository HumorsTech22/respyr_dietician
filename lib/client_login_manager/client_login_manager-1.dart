import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../client-dashboard/data/model/client_profile_model.dart';

class ClientLoginManager {

  Future<bool> saveClientProfile(ClientProfileModel profile) async {
    try {
      debugPrint("💾 saveClientProfile called");

      final prefs = await SharedPreferences.getInstance();

      String jsonString = jsonEncode(profile.toJson());

      debugPrint("📦 Profile JSON to save:");
      debugPrint(jsonString);

      final result = await prefs.setString('client_profile', jsonString);

      debugPrint("✅ Save result: $result");

      return result;
    } catch (e, stack) {
      debugPrint("❌ Error saving client profile");
      debugPrint("Error: $e");
      debugPrint("Stack: $stack");
      return false;
    }
  }

  Future<ClientProfileModel?> loadClientProfile() async {
    try {
      debugPrint("📂 loadClientProfile called");

      final prefs = await SharedPreferences.getInstance();

      String? jsonString = prefs.getString('client_profile');

      if (jsonString == null) {
        debugPrint("⚠️ No client_profile found in SharedPreferences");
        return null;
      }

      debugPrint("📦 Loaded JSON string:");
      debugPrint(jsonString);

      Map<String, dynamic> jsonMap = jsonDecode(jsonString);

      debugPrint("📊 Decoded JSON Map:");
      debugPrint(jsonMap.toString());

      final profile = ClientProfileModel.fromJson(jsonMap);

      debugPrint("👤 ClientProfileModel created successfully");

      return profile;
    } catch (e, stack) {
      debugPrint("❌ Error loading client profile");
      debugPrint("Error: $e");
      debugPrint("Stack: $stack");
      return null;
    }
  }

  Future<bool> clearClientProfile() async {
    try {
      debugPrint("🗑 clearClientProfile called");

      final prefs = await SharedPreferences.getInstance();

      final result = await prefs.remove('client_profile');

      debugPrint("🧹 Remove result: $result");

      return result;
    } catch (e, stack) {
      debugPrint("❌ Error clearing client profile");
      debugPrint("Error: $e");
      debugPrint("Stack: $stack");
      return false;
    }
  }
}