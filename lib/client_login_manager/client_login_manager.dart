import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../client-dashboard/data/model/client_profile_model.dart';

class ClientLoginManager {
  static const String _clientProfileKey = 'client_profile';

  Future<bool> saveClientProfile(ClientProfileModel profile) async {
    try {
      debugPrint("💾 saveClientProfile called");

      final prefs = await SharedPreferences.getInstance();
      final String jsonString = jsonEncode(profile.toJson());

      debugPrint("📦 Profile JSON to save:");
      debugPrint(jsonString);

      final bool result = await prefs.setString(_clientProfileKey, jsonString);

      debugPrint("✅ Save result: $result");

      final String? verify = prefs.getString(_clientProfileKey);
      debugPrint("🔍 Verify saved value exists: ${verify != null}");

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
      final String? jsonString = prefs.getString(_clientProfileKey);

      if (jsonString == null || jsonString.trim().isEmpty) {
        debugPrint("⚠️ No client_profile found in SharedPreferences");
        return null;
      }

      debugPrint("📦 Loaded JSON string:");
      debugPrint(jsonString);

      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);

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

      final bool existedBefore = prefs.containsKey(_clientProfileKey);
      debugPrint("🔍 Key existed before remove: $existedBefore");

      final bool removed = await prefs.remove(_clientProfileKey);
      debugPrint("🧹 Remove result: $removed");

      await prefs.reload();

      final bool existsAfter = prefs.containsKey(_clientProfileKey);
      final String? valueAfter = prefs.getString(_clientProfileKey);

      debugPrint("🔍 Key exists after remove: $existsAfter");
      debugPrint("🔍 Value after remove: $valueAfter");

      return !existsAfter && valueAfter == null;
    } catch (e, stack) {
      debugPrint("❌ Error clearing client profile");
      debugPrint("Error: $e");
      debugPrint("Stack: $stack");
      return false;
    }
  }

  Future<bool> isClientLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getString(_clientProfileKey);
      return value != null && value.trim().isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}