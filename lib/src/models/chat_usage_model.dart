class ChatUsageModel {
  int promptTokens;
  int completionTokens;
  int totalTokens;

  ChatUsageModel(
    this.promptTokens,
    this.completionTokens,
    this.totalTokens,
  );

  factory ChatUsageModel.fromJson(Map<String, dynamic> json) =>
      ChatUsageModel(
        json['prompt_tokens'] as int,
        json['completion_tokens'] as int,
        json['total_tokens'] as int,
      );

  Map<String, dynamic> toJson() => {
        'prompt_tokens': promptTokens,
        'completion_tokens': completionTokens,
        'total_tokens': totalTokens,
      };
}
