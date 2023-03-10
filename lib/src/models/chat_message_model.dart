class ChatMessageModel {
  final String role;
  String content;

  ChatMessageModel(
    this.role,
    this.content,
  );

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      ChatMessageModel(
        json['role'] as String,
        json['content'] as String,
      );

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
      };
}
