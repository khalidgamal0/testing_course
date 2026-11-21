import 'package:dio/dio.dart';

import '../../features/models/gemini_message_model.dart';
import 'api_client.dart';

class GeminiService {
  final ApiClient _apiClient;

  GeminiService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<GeminiMessageModel> sendMessage(GeminiMessageModel request) async {
    late Exception exception;
    for (int i = 0; i < 3; i++) {
      try {
        final response = await _apiClient.post(
          data: request.toJson(),
          headers: {
            'x-goog-api-key':
                'AQ.Ab8RN6JfbxBDkYZL_x_fDJ2i6ZtcdFq7bGTjPSLMpECDkE7rbQ',
            'Content-Type': 'application/json',
            'Api-Revision': '2026-05-20',
          },
        );

        return GeminiMessageModel.fromJson(
          Map<String, dynamic>.from(response.data),
        );
      } on DioException catch (e) {
        exception = e;
        if (!_isRetriableDioException(e)) rethrow;
      }
    }
    throw exception;
  }

  bool _isRetriableDioException(DioException e) {
    final statusCode = e.response?.statusCode;
    if (statusCode != null) {
      return statusCode == 408 || statusCode == 429 || statusCode >= 500;
    }

    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.connectionError => true,
      _ => false,
    };
  }
}
// mock ApiClient
// case 1 success at first attempt
// case 2 fail at 1 but success at 2 attempt
// case 3 fail at 1 but cant attempt
// case 4 fail at 1 but success at 3 attempt
// case 5 fail at 3
