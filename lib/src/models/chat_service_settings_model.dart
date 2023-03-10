import 'package:chat_gpt/src/models/chat_message_model.dart';

class ChatServiceSettingsModel {
  final String? model;
  final List<ChatMessageModel>? messages;
  final String? suffix;
  final double temperature;
  final int maxTokens;
  final double topP;
  final String? stop;

  ChatServiceSettingsModel(
    this.model,
    this.messages,
    this.suffix,
    this.temperature,
    this.maxTokens,
    this.topP,
    this.stop,
  );

  factory ChatServiceSettingsModel.fromJson(Map<String, dynamic> json) =>
      ChatServiceSettingsModel(
        json['model'] as String,
        (json['messages'] as List).map((p) => ChatMessageModel.fromJson(p)).toList(),
        json['suffix'] as String,
        json['temperature'] as double,
        json['maxTokens'] as int,
        json['topP'] as double,
        json['stop'] as String,
      );

  Map<String, dynamic> toJson() => {
        'model': model,
        'messages': messages,
        'suffix': suffix,
        'temperature': temperature,
        'maxTokens': maxTokens,
        'topP': topP,
        'stop': stop,
      };
}
