import 'package:chat_gpt/src/models/settings_model.dart';

abstract class SettingsState {}

class LoadedSettingsState extends SettingsState {
  final SettingsModel settingsModel;

  LoadedSettingsState({
    required this.settingsModel,
  });
}