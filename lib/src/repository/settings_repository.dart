import 'dart:convert';

import 'package:chat_gpt/src/models/settings_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<void> saveSettings(double temperature, int maxTokens, String? apiKey,
      String model, String directions) async {
    SettingsModel settingsModel = SettingsModel(
        temperature: temperature,
        maxTokens: maxTokens,
        apiKey: apiKey,
        model: model,
        directions: directions);
    var settingsJson = settingsModel.toJson();
    final SharedPreferences prefs = await _prefs;
    prefs.setString('settings', json.encode(settingsJson));
  }

  Future<SettingsModel> getSettings() async {
    final SharedPreferences prefs = await _prefs;
    var settingsJson = prefs.getString('settings');
    if (settingsJson == null) {
      return SettingsModel();
    } else {
      return SettingsModel.fromJson(jsonDecode(settingsJson));
    }
  }
}
