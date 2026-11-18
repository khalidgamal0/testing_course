import '../gemini_message_model.dart';

abstract interface class SendMessageRepository {
  Future<GeminiMessageModel> sendMessage(GeminiMessageModel request);
}
