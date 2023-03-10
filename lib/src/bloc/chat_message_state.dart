import 'package:chat_gpt/src/viewmodels/chat_message_viewmodel.dart';

abstract class ChatMessageState {}

/// 대화 리스트 상태
class ChatListMessageState extends ChatMessageState {
  final List<ChatMessageViewModel> chatMessageList;

  ChatListMessageState(this.chatMessageList);
}

/// 대화 메세지 상태 변경
class ChatMessageChangeState extends ChatMessageState {
  final ChatMessageViewModel chatMessage;

  ChatMessageChangeState(this.chatMessage);
}