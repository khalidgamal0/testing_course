import '../models/gemini_message_model.dart';

sealed class GeminiState {
  final List<GeminiMessageModel> messages;

  GeminiState({List<GeminiMessageModel> messages = const []})
    : messages = List.unmodifiable(messages);
}

final class GeminiInitial extends GeminiState {
  GeminiInitial({super.messages = const []});
}

final class GeminiLoading extends GeminiState {
  GeminiLoading({required super.messages});
}

final class GeminiSuccess extends GeminiState {
  final GeminiMessageModel response;

  GeminiSuccess(this.response, {required super.messages});
}

final class GeminiFailure extends GeminiState {
  final String errorMessage;

  GeminiFailure(this.errorMessage, {required super.messages});
}
