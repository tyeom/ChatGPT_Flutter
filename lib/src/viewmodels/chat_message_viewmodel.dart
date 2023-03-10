class ChatMessageViewModel {
  String? prompt;
  String message;
  bool isSent;
  bool isAwaiting;
  bool isError;
  bool canRemove;
  bool isEditing;
  ChatMessageViewModel? result;

  ChatMessageViewModel(this.prompt, this.message,
      {this.isSent = false,
      this.isAwaiting = false,
      this.isError = false,
      this.canRemove = false,
      this.isEditing = false,
      this.result});
}
