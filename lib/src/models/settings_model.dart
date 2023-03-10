class SettingsModel {
  final double temperature;
  final int maxTokens;
  final String? apiKey;
  final String model;
  final String directions;

  SettingsModel({
    this.temperature = 0.7,
    this.maxTokens = 256,
    this.apiKey,
    this.model = 'gpt-3.5-turbo',
    this.directions =
        'You are a helpful assistant named Clippy. Write answers in Markdown blocks. For code blocks always define used language.',
  });

  factory SettingsModel.fromJson(Map<String, dynamic> json) => SettingsModel(
      temperature: json['temperature'] as double,
      maxTokens: json['maxTokens'] as int,
      apiKey: json['apiKey'] as String,
      model: json['model'] as String,
      directions: json['directions'] as String);

  Map<String, dynamic> toJson() => {
        'temperature': temperature,
        'maxTokens': maxTokens,
        'apiKey': apiKey,
        'model': model,
        'directions': directions,
      };
}
