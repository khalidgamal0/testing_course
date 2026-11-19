import '../../features/models/gemini_message_model.dart';
import 'api_client.dart';

class GeminiService {
  final ApiClient _apiClient;

  GeminiService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<GeminiMessageModel> sendMessage(GeminiMessageModel request) async {
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
  }
}
