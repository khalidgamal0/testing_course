import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../features/models/gemini_message_model.dart';
import 'api_client.dart';

const _geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');

class GeminiService {
  final ApiClient _apiClient;

  GeminiService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<GeminiMessageModel> sendMessage(GeminiMessageModel request) async {
    if (_geminiApiKey.isEmpty) {
      throw StateError(
        'Missing GEMINI_API_KEY. Run Flutter with '
        '--dart-define=GEMINI_API_KEY=your_key.',
      );
    }

    final requestBody = request.toJson();
    _logBody('Request', requestBody);

    try {
      final response = await _apiClient.post(
        data: requestBody,
        headers: {
          'x-goog-api-key': _geminiApiKey,
          'Content-Type': 'application/json',
          'Api-Revision': '2026-05-20',
        },
      );
      _logBody('Response', response.data);

      return GeminiMessageModel.fromJson(
        Map<String, dynamic>.from(response.data),
      );
    } on DioException catch (error) {
      _logBody('Error response', error.response?.data ?? error.message);
      rethrow;
    }
  }

  void _logBody(String label, Object? body) {
    if (!kDebugMode) return;

    try {
      debugPrint(
        'Gemini API $label body:\n${const JsonEncoder.withIndent('  ').convert(body)}',
      );
    } catch (_) {
      debugPrint('Gemini API $label body:\n$body');
    }
  }
}
