import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/gemini_message_model.dart';
import '../models/repositories/send_message_repository.dart';
import 'send_message_state.dart';

class SendMessageCubit extends Cubit<GeminiState> {
  final SendMessageRepository repository;
  List<GeminiMessageModel> _messages = const [];

  SendMessageCubit({required this.repository}) : super(GeminiInitial());

  Future<void> addMessage(GeminiMessageModel request) async {
    if (!request.isUser || request.text.trim().isEmpty) return;

    if (_messages.isEmpty || !identical(_messages.last, request)) {
      _messages = List.unmodifiable([..._messages, request]);
    }
    await _sendRequest(request);
  }

  Future<void> _sendRequest(GeminiMessageModel request) async {
    emit(GeminiLoading(messages: _messages));

    try {
      final response = await repository.sendMessage(request);
      _messages = List.unmodifiable([..._messages, response]);
      emit(GeminiSuccess(response, messages: _messages));
    } catch (error) {
      emit(GeminiFailure(error.toString(), messages: _messages));
    }
  }
}
