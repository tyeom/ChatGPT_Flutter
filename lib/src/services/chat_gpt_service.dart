import 'dart:convert';
import 'dart:io';

import 'package:chat_gpt/src/models/chat_response_model.dart';
import 'package:chat_gpt/src/models/chat_service_settings_model.dart';
import 'package:dio/dio.dart';

import '../models/chat_request_body_model.dart';

class ChatGptService {
  Future<ChatResponseModel?> getResponseDataAsync(
      ChatServiceSettingsModel settings, String? apiKey) async {
    // Set up the API URL and API key
    var apiUrl = "https://api.openai.com/v1/chat/completions";

    if (apiKey == null) {
      return null;
    }

    // Get the request body JSON
    var requestBodyJson = _getRequestBodyJson(settings);

    // Send the API request and get the response data
    return await sendApiRequestAsync(apiUrl, apiKey, requestBodyJson);
  }

  String _getRequestBodyJson(ChatServiceSettingsModel settings) {
    ChatRequestBodyModel requestBody = ChatRequestBodyModel(
        settings.model,
        settings.messages,
        settings.temperature,
        settings.topP,
        1,
        false,
        settings.stop,
        settings.maxTokens,
        0.0,
        0.0,
        null,
        null);

    var requestMap = requestBody.toJson();
    requestMap.removeWhere((key, value) => value == null);

    return json.encode(requestMap);
  }

  Future<ChatResponseModel?> sendApiRequestAsync(
      String apiUrl, String apiKey, String requestBodyJson) async {
    var dio = Dio(BaseOptions(
      responseType: ResponseType.json,
      contentType: ContentType.json.toString(),
    ));
    dio.options.headers["Authorization"] = "Bearer $apiKey";
    Response<Map<String, dynamic>> resposne =
        await dio.post(apiUrl, data: requestBodyJson);
    if (resposne.statusCode != 200) {
      return null;
    }

    switch (resposne.statusCode) {
      case 401:
      case 429:
      case 500:
        return ChatResponseErrorModel.fromJson(resposne.data!);
    }

    return ChatResponseSuccessModel.fromJson(resposne.data!);
  }
}
