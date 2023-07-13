import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

class Config {
  static const String fileName = 'config.json';

  static Future<void> saveSettings(Map<String, dynamic> settings) async {
    final file = File(fileName);
    Map<String, dynamic> existingSettings = await loadSettings();
    existingSettings.addAll(settings);
    await file.writeAsString(jsonEncode(existingSettings));
    if (kDebugMode) {
      print('save settings success');
    }
  }

  static Future<Map<String, dynamic>> loadSettings() async {
    try {
      final file = File(fileName);
      if (await file.exists()) {
        final contents = await file.readAsString();
        return jsonDecode(contents);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to load settings: $e');
      }
    }
    return {};
  }
}
