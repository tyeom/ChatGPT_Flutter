class ChatMessageViewModel {
  String? prompt;
  String message;
  bool isSent;
  bool isAwaiting;
  bool isError;
  bool canRemove;
  bool isEditing;
  ChatMessageViewModel? result;

  // 음성 인식 관련
  bool speechRecognitionAvailable;
  bool isListening;
  String transcription;
  bool speechRecognitionError;

  ChatMessageViewModel(
    this.prompt,
    this.message, {
    this.isSent = false,
    this.isAwaiting = false,
    this.isError = false,
    this.canRemove = false,
    this.isEditing = false,
    this.speechRecognitionAvailable = false,
    this.isListening = false,
    this.transcription = '',
    this.speechRecognitionError = false,
    this.result,
  });
}
