class GeminiMessageModel {
  final String? id;
  final String status;
  final String model;
  final String? input;
  final String? previousInteractionId;
  final bool isUser;
  final List<GeminiContent> content;
  final Map<String, dynamic>? responseBody;

  const GeminiMessageModel({
    this.id,
    this.status = '',
    this.model = 'gemini-4-hydrogen',
    this.input,
    this.previousInteractionId,
    this.isUser = false,
    this.content = const [],
    this.responseBody,
  });

  factory GeminiMessageModel.user(
    String text, {
    String model = 'gemini-4-hydrogen',
    String? previousInteractionId,
  }) {
    return GeminiMessageModel(
      model: model,
      input: text,
      previousInteractionId: previousInteractionId,
      isUser: true,
      content: [GeminiContent(type: 'text', text: text)],
    );
  }

  factory GeminiMessageModel.local({
    required String text,
    required bool isUser,
  }) {
    return GeminiMessageModel(
      input: isUser ? text : null,
      isUser: isUser,
      content: [GeminiContent(type: 'text', text: text)],
    );
  }

  factory GeminiMessageModel.fromJson(Map<String, dynamic> json) {
    final steps = (json['steps'] as List? ?? []).whereType<Map>();
    final parsedContent = steps
        .expand((step) => (step['content'] as List? ?? []))
        .whereType<Map>()
        .map((item) => GeminiContent.fromJson(Map<String, dynamic>.from(item)))
        .toList();

    return GeminiMessageModel(
      id: json['id'] as String?,
      status: json['status'] as String? ?? '',
      model: json['model'] as String? ?? 'gemini-4-hydrogen',
      isUser: false,
      content: parsedContent,
      responseBody: Map.unmodifiable(json),
    );
  }

  Map<String, dynamic> toJson() {
    final requestInput = input;
    if (requestInput == null) {
      throw StateError('Only user request messages can be sent to Gemini.');
    }

    return {
      'model': model,
      'input': requestInput,
      if (previousInteractionId != null)
        'previous_interaction_id': previousInteractionId,
    };
  }

  String get text => content
      .where((item) => item.text != null)
      .map((item) => item.text!)
      .join('\n');

  bool get isCompleted => status == 'completed';

  bool get isFailed => status == 'failed';

  bool get isInProgress => status == 'in_progress';
}

class GeminiContent {
  final String type;
  final String? text;

  const GeminiContent({required this.type, this.text});

  factory GeminiContent.fromJson(Map<String, dynamic> json) {
    return GeminiContent(
      type: json['type'] as String? ?? '',
      text: json['text'] as String?,
    );
  }
}
