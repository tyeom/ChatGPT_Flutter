import 'dart:convert';

import 'package:chat_gpt/src/models/settings_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  Future<void> saveSettings(double temperature, int maxTokens, String? apiKey,
      String model, String directions) async {
    SettingsModel settingsModel = SettingsModel(
        temperature: temperature,
        maxTokens: maxTokens,
        apiKey: apiKey,
        model: model,
        directions: directions);
    var settingsJson = settingsModel.toJson();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('settings', json.encode(settingsJson));
  }

  Future<SettingsModel> getSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var settingsJson = prefs.getString('settings');
    if (settingsJson == null) {
      return SettingsModel();
    } else {
      return SettingsModel.fromJson(jsonDecode(settingsJson));
    }
  }
}
