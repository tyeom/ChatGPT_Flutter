import 'package:chat_gpt/src/bloc/settings_cubit.dart';
import 'package:chat_gpt/src/bloc/settings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:number_inc_dec/number_inc_dec.dart';

class PopupItemSettings extends StatelessWidget {
  final TextEditingController _temperatureText = TextEditingController();
  final TextEditingController _maxtokensText = TextEditingController();
  final TextEditingController _directionsText = TextEditingController();
  final TextEditingController _modelText = TextEditingController();
  final TextEditingController _apiKeyText = TextEditingController();

  PopupItemSettings({super.key});

  void _updateSettings(BuildContext context) {
    context.read<SettingsCubit>().updateSettings(
        double.parse(_temperatureText.text),
        int.parse(_maxtokensText.text),
        _apiKeyText.text,
        _modelText.text,
        _directionsText.text);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: BlocBuilder<SettingsCubit, SettingsState>(builder: (_, state) {
          LoadedSettingsState settingsState = state as LoadedSettingsState;
          _apiKeyText.text = (settingsState.settingsModel.apiKey == null)
              ? ""
              : settingsState.settingsModel.apiKey!;
          _modelText.text = settingsState.settingsModel.model;
          _directionsText.text = settingsState.settingsModel.directions;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Temperature:'),
              const SizedBox(
                height: 10,
              ),
              NumberInputWithIncrementDecrement(
                controller: _temperatureText,
                isInt: false,
                incDecFactor: 0.1,
                initialValue: settingsState.settingsModel.temperature,
                min: 0,
                onDecrement: (value) => _updateSettings(context),
                onIncrement: (value) => _updateSettings(context),
                onChanged: (value) => _updateSettings(context),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text('Max tokens:'),
              const SizedBox(
                height: 10,
              ),
              NumberInputWithIncrementDecrement(
                controller: _maxtokensText,
                isInt: true,
                incDecFactor: 1,
                initialValue: settingsState.settingsModel.maxTokens,
                min: 0,
                onDecrement: (value) => _updateSettings(context),
                onIncrement: (value) => _updateSettings(context),
                onChanged: (value) => _updateSettings(context),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text('Directions:'),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: _directionsText,
                keyboardType: TextInputType.text,
                maxLines: 3,
                onChanged: (value) => _updateSettings(context),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text('Model:'),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: _modelText,
                keyboardType: TextInputType.text,
                onChanged: (value) => _updateSettings(context),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text('Api Key:'),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: _apiKeyText,
                keyboardType: TextInputType.text,
                onChanged: (value) => _updateSettings(context),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          );
        }),
      ),
    );
  }
}
