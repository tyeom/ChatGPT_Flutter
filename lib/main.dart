import 'package:chat_gpt/src/bloc/chat_message_cubit.dart';
import 'package:chat_gpt/src/bloc/settings_cubit.dart';
import 'package:chat_gpt/src/bloc/theme_cubit.dart';
import 'package:chat_gpt/src/repository/settings_repository.dart';
import 'package:chat_gpt/src/services/chat_gpt_service.dart';
import 'package:chat_gpt/src/views/app_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (_) => ThemeCubit(),
      ),
      BlocProvider(
        create: (_) => SettingsCubit(settingsRepository: SettingsRepository()),
      ),
      BlocProvider(
        create: (_) => ChatMessageCubit(
            chatGptService: ChatGptService(),
            settingsRepository: SettingsRepository()),
      ),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeData>(
      builder: (_, theme) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'ChatGPT',
          theme: theme,
          home: const AppView(),
        );
      },
    );
  }
}
