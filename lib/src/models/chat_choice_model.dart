import 'package:chat_gpt/src/models/chat_message_model.dart';

class ChatChoiceModel {
  ChatMessageModel message;
  int index;
  Object? logprobs;
  String? finishReason;

  ChatChoiceModel(
    this.message,
    this.index,
    this.logprobs,
    this.finishReason,
  );

  factory ChatChoiceModel.fromJson(Map<String, dynamic> json) =>
      ChatChoiceModel(
        ChatMessageModel.fromJson(json['message']),
        json['index'] as int,
        json['logprobs'] as Object?,
        json['finish_reason'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'message': message,
        'index': index,
        'logprobs': logprobs,
        'finish_reason': finishReason,
      };
}
