import '../gemini_message_model.dart';
import '../../../core/services/gemini_service.dart';

abstract interface class SendMessageRepository {
  Future<GeminiMessageModel> sendMessage(GeminiMessageModel request);
}

class GeminiRepositoryImpl implements SendMessageRepository {
  final GeminiService _geminiService;

  GeminiRepositoryImpl({required GeminiService geminiService})
    : _geminiService = geminiService;

  @override
  Future<GeminiMessageModel> sendMessage(GeminiMessageModel request) {
    return _geminiService.sendMessage(request);
  }
}
