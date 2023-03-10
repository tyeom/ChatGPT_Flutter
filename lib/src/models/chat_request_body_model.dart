import 'package:chat_gpt/src/models/chat_message_model.dart';

class ChatRequestBodyModel {
  String? model;
  List<ChatMessageModel>? messages;
  double temperature;
  double topP;
  int n;
  bool stream;
  String? stop;
  int maxTokens;
  double presencePenalty;
  double frequencyPenalty;
  Map<String, double>? logitBias;
  String? user;

  ChatRequestBodyModel(
    this.model,
    this.messages,
    this.temperature,
    this.topP,
    this.n,
    this.stream,
    this.stop,
    this.maxTokens,
    this.presencePenalty,
    this.frequencyPenalty,
    this.logitBias,
    this.user,
  );

  factory ChatRequestBodyModel.fromJson(Map<String, dynamic> json) =>
      ChatRequestBodyModel(
        json['model'] as String,
        (json['messages'] as List).map((p) => ChatMessageModel.fromJson(p)).toList(),
        json['temperature'] as double,
        json['top_p'] as double,
        json['n'] as int,
        json['stream'] as bool,
        json['stop'] as String,
        json['max_tokens'] as int,
        json['presence_penalty'] as double,
        json['frequency_penalty'] as double,
        json['logitBias'] as Map<String, double>,
        json['user'] as String,
      );

  Map<String, dynamic> toJson() => {
        'model': model,
        'messages': messages,
        'temperature': temperature,
        'top_p': topP,
        'n': n,
        'stream': stream,
        'stop': stop,
        'max_tokens': maxTokens,
        'presence_penalty': presencePenalty,
        'frequency_penalty': frequencyPenalty,
        'logitBias': logitBias,
        'user': user,
      };
}
