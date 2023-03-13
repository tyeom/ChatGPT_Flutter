import 'package:chat_gpt/src/models/chat_choice_model.dart';
import 'package:chat_gpt/src/models/chat_usage_model.dart';

abstract class ChatResponseModel {}

class ChatResponseErrorModel extends ChatResponseModel {
  String? message;
  String? type;
  Object? param;
  String? code;

  ChatResponseErrorModel(
    this.message,
    this.type,
    this.param,
    this.code,
  );

  factory ChatResponseErrorModel.fromJson(Map<String, dynamic> json) =>
      ChatResponseErrorModel(
        json['message'] as String?,
        json['type'] as String?,
        json['param'] as Object?,
        json['code'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'message': message,
        'type': type,
        'param': param,
        'code': code,
      };
}

class ChatResponseSuccessModel extends ChatResponseModel {
  String? id;
  Object? object;
  int created;
  String? model;
  List<ChatChoiceModel> choices;
  ChatUsageModel? usage;

  ChatResponseSuccessModel(
    this.id,
    this.object,
    this.created,
    this.model,
    this.choices,
    this.usage,
  );

  factory ChatResponseSuccessModel.fromJson(Map<String, dynamic> json) =>
      ChatResponseSuccessModel(
        json['id'] as String?,
        json['object'] as Object?,
        json['created'] as int,
        json['model'] as String?,
        (json['choices'] as List)
            .map((p) => ChatChoiceModel.fromJson(p))
            .toList(),
        ChatUsageModel.fromJson(json['usage']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'object': object,
        'created': created,
        'model': model,
        'choices': choices,
        'usage': usage,
      };
}
