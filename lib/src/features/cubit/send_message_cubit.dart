import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/gemini_message_model.dart';
import '../models/repositories/gemini_repository_impl.dart';
import 'send_message_state.dart';

class SendMessageCubit extends Cubit<GeminiState> {
  final SendMessageRepository repository;
  List<GeminiMessageModel> _messages = [];
  int _requestsInCurrentChain = 0;

  SendMessageCubit({required this.repository}) : super(GeminiInitial());

  Future<void> addMessage(GeminiMessageModel request) async {
    if (state is GeminiFailure) {
      _messages.removeAt(0);
    }
    _messages.insert(0, request);
    await sendRequest(request);
  }

  Future<void> sendRequest(GeminiMessageModel request) async {
    emit(GeminiLoading(messages: _messages));

    try {
      final startsNewChain = _requestsInCurrentChain > 20;
      final outgoingRequest = startsNewChain
          ? GeminiMessageModel.user(request.input!, model: request.model)
          : request;
      _logBody('Request', outgoingRequest.toJson());
      final response = await repository.sendMessage(outgoingRequest);
      _logBody('Response', response.responseBody);

      _requestsInCurrentChain = startsNewChain
          ? 1
          : _requestsInCurrentChain + 1;
      _messages = [response, ..._messages];
      emit(GeminiSuccess(response, messages: _messages));
    } catch (error, stackTrace) {
      _logError(error, stackTrace);
      emit(GeminiFailure(_extractErrorMessage(error), messages: _messages));
    }
  }

  void _logError(Object error, StackTrace stackTrace) {
    if (!kDebugMode) return;

    _logBody('Error', {
      'error': error.toString(),
      'stackTrace': stackTrace.toString(),
      if (error is DioException) ...{
        'type': error.type.name,
        'message': error.message,
        'cause': error.error?.toString(),
        'statusCode': error.response?.statusCode,
        'statusMessage': error.response?.statusMessage,
        'responseBody': error.response?.data,
      },
    });
  }

  void _logBody(String label, Object? body) {
    if (!kDebugMode) return;
    try {
      final json = const JsonEncoder.withIndent('  ').convert(body);
      debugPrint('Gemini API $label body:\n$json');
    } catch (_) {
      debugPrint('Gemini API $label body:\n$body');
    }
  }

  String _extractErrorMessage(Object error) {
    final dioError = error is DioException ? error : null;
    final body = dioError?.response?.data;
    final details = body is Map ? body['error'] : null;
    final serverMessage = details is Map ? details['message'] : null;
    return serverMessage is String && serverMessage.trim().isNotEmpty
        ? serverMessage
        : dioError?.message ?? error.toString();
  }
}
