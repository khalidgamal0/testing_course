import 'package:ai_chat/src/core/services/api_client.dart';
import 'package:ai_chat/src/core/services/gemini_service.dart';
import 'package:ai_chat/src/features/models/gemini_message_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockApiClient extends Mock implements ApiClient {}

Response<Map<String, dynamic>> _successResponse() {
  return Response<Map<String, dynamic>>(
    requestOptions: RequestOptions(path: '/interactions'),
    statusCode: 200,
    data: _response,
  );
}

DioException _retriableException() {
  return DioException(
    requestOptions: RequestOptions(path: '/interactions'),
    response: Response<void>(
      requestOptions: RequestOptions(path: '/interactions'),
      statusCode: 500,
    ),
    type: DioExceptionType.badResponse,
  );
}

DioException _nonRetriableException() {
  return DioException(
    requestOptions: RequestOptions(path: '/interactions'),
    response: Response<void>(
      requestOptions: RequestOptions(path: '/interactions'),
      statusCode: 404,
    ),
    type: DioExceptionType.badResponse,
  );
}

Map<String, dynamic> _response = {
  "id":
      "v1_ChdibHI3YW91SkhkM0ppTE1QaUlhRXlBbxIXc1Z2N2F2dUFQZDNKaUxNUGhyR0V5QW8",
  "status": "completed",
  "usage": {
    "total_tokens": 1521,
    "total_input_tokens": 1477,
    "input_tokens_by_modality": [
      {"modality": "text", "tokens": 1477},
    ],
    "total_cached_tokens": 0,
    "total_output_tokens": 28,
    "output_tokens_by_modality": [
      {"modality": "text", "tokens": 28},
    ],
    "total_tool_use_tokens": 0,
    "total_thought_tokens": 16,
    "initial_input_tokens": 1477,
  },
  "created": "2026-11-16T19:38:28Z",
  "updated": "2026-11-16T19:38:28Z",
  "service_tier": "standard",
  "steps": [
    {
      "signature":
          "EtEBCs4BAWkUfRNZsfEZ5BzwGKLfuY+CvoH+8Nw71IzxUkzKBG9l7c7SNsWfcSmpgMWmKh5jjdxnhBKhtbcf09LNm79+pqbWYwd5gT/SarNTc17EYYwORWRT2rWhMFEBM2oj16Y9nooIm4e0Td5L7IL1wtFGmGnIbao43v4vUYulEHfnHirndsR5ad9IJZe+l7glKkA8zMoMB3YQY5paYyitpOfT06e2LWdLEWMa+Stb64snNU1pz5Bc5GA7oVcJwxtv71qNruBN/vllwupRRDZI3WU=",
      "type": "thought",
    },
    {
      "content": [
        {
          "text":
              "You're welcome! Let me know if you want to dive deeper into any part of it or have other questions.",
          "type": "text",
        },
      ],
      "type": "model_output",
    },
  ],
  "object": "interaction",
  "model": "gemini-4-hydrogen",
};

void main() {
  late MockApiClient mockApiClient;
  late GeminiService geminiService;

  setUp(() {
    mockApiClient = MockApiClient();
    geminiService = GeminiService(apiClient: mockApiClient);
  });

  group('retry logic ', () {
    test('success on first attempt', () async {
      when(
        () => mockApiClient.post(
          data: any(named: 'data'),
          headers: any(named: 'headers'),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => _successResponse());

      var result = await geminiService.sendMessage(
        GeminiMessageModel.local(text: 'text', isUser: true),
      );
      int count = verify(
        () => mockApiClient.post(
          data: any(named: 'data'),
          headers: any(named: 'headers'),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).callCount;

      expect(count, equals(1));
      expect(result, isA<GeminiMessageModel>());
    });

    test(' fail at 1 but success at 2 attempt', () async {
      int counter = 0;
      when(
        () => mockApiClient.post(
          data: any(named: 'data'),
          headers: any(named: 'headers'),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async {
        if (counter++ == 0) {
          throw _retriableException();
        }
        return _successResponse();
      });

      var result = await geminiService.sendMessage(
        GeminiMessageModel.local(text: 'text', isUser: true),
      );
      int count = verify(
        () => mockApiClient.post(
          data: any(named: 'data'),
          headers: any(named: 'headers'),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).callCount;

      expect(count, equals(2));
      expect(result, isA<GeminiMessageModel>());
    });

    test('fail at 1 but cant attempt ', () async {
      when(
        () => mockApiClient.post(
          data: any(named: 'data'),
          headers: any(named: 'headers'),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => throw _nonRetriableException());

      await expectLater(
        () => geminiService.sendMessage(
          GeminiMessageModel.local(text: 'text', isUser: true),
        ),
        throwsA(isA<DioException>()),
      );

      int count = verify(
        () => mockApiClient.post(
          data: any(named: 'data'),
          headers: any(named: 'headers'),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).callCount;

      expect(count, equals(1));
    });

    test(' fail at 1 but success at 3 attempt', () async {
      int counter = 0;
      when(
            () => mockApiClient.post(
          data: any(named: 'data'),
          headers: any(named: 'headers'),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async {
        counter++;
        if (counter == 3) {
          return _successResponse();

        }
        throw _retriableException();
      });

      var result = await geminiService.sendMessage(
        GeminiMessageModel.local(text: 'text', isUser: true),
      );
      int count = verify(
            () => mockApiClient.post(
          data: any(named: 'data'),
          headers: any(named: 'headers'),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).callCount;

      expect(count, equals(3));
      expect(result, isA<GeminiMessageModel>());
    });


    test('fail at all attempts ', () async {
      when(
            () => mockApiClient.post(
          data: any(named: 'data'),
          headers: any(named: 'headers'),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => throw _retriableException());

      await expectLater(
            () => geminiService.sendMessage(
          GeminiMessageModel.local(text: 'text', isUser: true),
        ),
        throwsA(isA<DioException>()),
      );

      int count = verify(
            () => mockApiClient.post(
          data: any(named: 'data'),
          headers: any(named: 'headers'),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).callCount;

      expect(count, equals(3));
    });


  });
}
