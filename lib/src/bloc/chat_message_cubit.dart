import 'package:chat_gpt/src/bloc/chat_message_state.dart';
import 'package:chat_gpt/src/models/chat_message_model.dart';
import 'package:chat_gpt/src/models/chat_response_model.dart';
import 'package:chat_gpt/src/models/chat_service_settings_model.dart';
import 'package:chat_gpt/src/repository/settings_repository.dart';
import 'package:chat_gpt/src/services/chat_gpt_service.dart';
import 'package:chat_gpt/src/viewmodels/chat_message_viewmodel.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatMessageCubit extends Cubit<ChatMessageState> {
  final ChatGptService chatGptService;
  final SettingsRepository settingsRepository;
  final List<ChatMessageViewModel> _chatMessageList = [];

  ChatMessageCubit({
    required this.chatGptService,
    required this.settingsRepository,
  }) : super(ChatListMessageState([]));

  void getChatMessageData() {
    if (_chatMessageList.isEmpty) {
      // 최초 시작시 보여지는 고정 메세지
      _chatMessageList.add(ChatMessageViewModel(
        null,
        "Hi! I'm Clippy, your Windows Assistant. Would you like to get some assistance?",
      ));
    }
    emit(ChatListMessageState(_chatMessageList));
  }

  /// 메세지 삭제
  removeChatMessage(ChatMessageViewModel chatMessage) {
    _chatMessageList.remove(chatMessage);
    emit(ChatListMessageState(_chatMessageList));

    _chatMessageList.last.isSent = false;
    emit(ChatMessageChangeState(_chatMessageList.last));
  }

  // 메세지 수정
  editChatMessage(ChatMessageViewModel chatMessage) {
    chatMessage.isEditing = !chatMessage.isEditing;
    emit(ChatMessageChangeState(chatMessage));
  }

  // 메세지 전송
  Future<void> sendChatMessage(ChatMessageViewModel sendMessage) async {
    try {
      // load 환경설정 데이터
      var userSettings = await settingsRepository.getSettings();

      // ChatGPT API - Send 요청시 지난 대화 기록 포함하여 요청
      List<ChatMessageModel> chatMessageList = [
        ChatMessageModel('system', userSettings.directions),
      ];

      for (var chatMessage in _chatMessageList) {
        if (chatMessage.message.isNotEmpty && chatMessage.result != null) {
          chatMessageList.add(ChatMessageModel('user', chatMessage.message));
          chatMessageList
              .add(ChatMessageModel('assistant', chatMessage.result!.message));
        }
      }

      // sendChatMessage 메서드 호출시는 chatMessage.prompt 속성이 null이 될 수 없다.
      chatMessageList.add(ChatMessageModel('user', sendMessage.prompt!));

      bool isUpdate = false;
      var last = _chatMessageList.last;
      // 중간 대화 메세지 수정 해서 전송 한 경우
      if (last.hashCode != sendMessage.hashCode) {
        sendMessage.isAwaiting = true;
        isUpdate = true;
        sendMessage.isEditing = false;
        // 중간 대화 메세지 수정 후 전송처리 상태 변경
        emit(ChatMessageChangeState(sendMessage));
      }

      // user 입력 메세지
      ChatMessageViewModel promptMessage;
      // 전송한 메세지에 대한 결과
      ChatMessageViewModel resultMessage;

      sendMessage.isSent = true;

      if (isUpdate == false) {
        // user 입력 메세지
        promptMessage = ChatMessageViewModel(
          null,
          sendMessage.prompt!,
          canRemove: true,
          isSent: true,
          // 전송 요청 대기
          isAwaiting: true,
        );
        // 전송한 메세지에 대한 결과
        resultMessage = ChatMessageViewModel(
          null,
          "",
          canRemove: true,
        );

        promptMessage.result = resultMessage;
      } else {
        var prompt = sendMessage.prompt!;
        promptMessage = sendMessage;
        promptMessage.message = prompt;
        resultMessage = sendMessage.result!;
      }

      if (isUpdate == false) {
        // user 입력 메세지 기록 추가
        _chatMessageList.add(promptMessage);
        emit(ChatListMessageState(_chatMessageList));
      }

      // ChatGPT Send API 요청에 필요한 데이터 모델
      ChatServiceSettingsModel chatServiceSettings = ChatServiceSettingsModel(
          userSettings.model,
          chatMessageList,
          null,
          userSettings.temperature,
          userSettings.maxTokens,
          1.0,
          null);

      // 실제 ChatGPT 대화 Send API 요청
      var responseData = await chatGptService.getResponseDataAsync(
          chatServiceSettings, userSettings.apiKey);

      // 전송 완료
      promptMessage.isAwaiting = false;

      // 요청 완료 이벤트 발생 - isAwaiting = false 상태 변경
      emit(ChatMessageChangeState(promptMessage));

      // 응답 오류 발생시
      if (responseData is ChatResponseErrorModel) {
        var error = responseData;

        resultMessage.isError = true;
        // ChatGPT에서 오류 메세지 반환
        if (error.message != null) {
          resultMessage.message = error.message!;
        }
        // ChatGPT에서 오류 메세지 반환 없음
        else {
          resultMessage.message = '알 수 없는 Error 발생, 다시 시도해보세요!';
        }
      }
      // 정상 응답
      else {
        var responseSuccess = responseData as ChatResponseSuccessModel;

        // 전송한 메세지에 대한 결과
        resultMessage.message =
            responseSuccess.choices.first.message.content.trim();
      }

      if (isUpdate == false) {
        // 메세지 결과 기록 추가
        _chatMessageList.add(resultMessage);
        // 요청 결과 완료 이벤트 발생
        emit(ChatListMessageState(_chatMessageList));
      } else {
        // 요청 결과 완료 이벤트 발생
        emit(ChatMessageChangeState(resultMessage));
      }
    } catch (ex) {
      print(ex.toString());
    }
  }
}
