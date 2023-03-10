import 'package:chat_gpt/src/bloc/settings_state.dart';
import 'package:chat_gpt/src/models/settings_model.dart';
import 'package:chat_gpt/src/repository/settings_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository settingsRepository;

  // Repository 생성자 의존성 주입 처리
  SettingsCubit({
    required this.settingsRepository,
  }) : super(LoadedSettingsState(settingsModel: SettingsModel()));

  Future<void> updateSettings(
      double temperature, int maxTokens, String? apiKey, String model, String directions) async {
    try {
      await settingsRepository.saveSettings(temperature, maxTokens, apiKey, model, directions);
      final settingsModel = await settingsRepository.getSettings();

      emit(LoadedSettingsState(settingsModel: settingsModel));
    } catch (ex) {
      print(ex.toString());
    }
  }

  Future<void> getSettings() async {
    try {
      final settingsModel = await settingsRepository.getSettings();
      emit(LoadedSettingsState(settingsModel: settingsModel));
    } catch (ex) {
      print(ex.toString());
    }
  }
}
