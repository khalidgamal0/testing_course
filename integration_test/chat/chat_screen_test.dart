import 'dart:async';
import 'package:ai_chat/src/app.dart';
import 'package:ai_chat/src/core/services/api_client.dart';
import 'package:ai_chat/src/core/services/get_it.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';

class MockApiClient extends Mock implements ApiClient {}

const _replyText = 'Hello from Gemini';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockApiClient mockApiClient;
  late Future<Response<dynamic>> Function(String input) respond;
  late List<String> sentMessages;

  setUp(() async {
    mockApiClient = MockApiClient();
    sentMessages = [];
    setupDependencies();
    // Replace ApiClient before the app creates the service that uses it.
    await getIt.unregister<ApiClient>();
    getIt.registerSingleton<ApiClient>(mockApiClient);

    when(
      () => mockApiClient.post(
        data: any(named: 'data'),
        headers: any(named: 'headers'),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer((invocation) {
      final body = invocation.namedArguments[#data] as Map<String, dynamic>;
      final input = body['input'] as String;
      sentMessages.add(input);
      return respond(input);
    });
  });

  tearDown(() async {
    await getIt.reset();
  });

  group('ChatScreen', () {
    testWidgets('shows loading while sending a message', (tester) async {
      final response = Completer<Response<dynamic>>();
      respond = (_) => response.future;
      await _pumpChat(tester);

      await _sendMessage(tester, 'Hello');
      await tester.pump();
      expect(find.text('Thinking...'), findsOneWidget);

      response.complete(_successResponse());
      await tester.pumpAndSettle();
      expect(find.text('Thinking...'), findsNothing);
    });

    testWidgets('shows the reply after sending a message', (tester) async {
      respond = (_) async => _successResponse();
      await _pumpChat(tester);

      await _sendMessage(tester, 'Hello');
      await tester.pumpAndSettle();

      expect(find.text('Hello'), findsOneWidget);
      expect(find.text(_replyText), findsOneWidget);
      expect(sentMessages, ['Hello']);
    });

    testWidgets('shows the reply after a successful retry', (tester) async {
      respond = (_) async {
        if (sentMessages.length == 1) throw _apiError('Send failed');
        return _successResponse();
      };
      await _pumpChat(tester);

      await _sendMessage(tester, 'Hello');
      await tester.pumpAndSettle();
      expect(find.text('Send failed'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(find.text(_replyText), findsOneWidget);
      expect(find.text('Send failed'), findsNothing);
      expect(find.text('Retry'), findsNothing);
      expect(sentMessages, ['Hello', 'Hello']);
    });

    testWidgets('shows the new error when Retry also fails', (tester) async {
      respond = (_) async {
        // Each send makes up to three API calls for a 500 response.
        final message = sentMessages.length <= 3
            ? 'Send failed'
            : 'Retry failed';
        throw _apiError(message, statusCode: 500);
      };
      await _pumpChat(tester);

      await _sendMessage(tester, 'Hello');
      await tester.pumpAndSettle();
      expect(find.text('Send failed'), findsOneWidget);
      expect(sentMessages, List.filled(3, 'Hello'));

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(find.text('Retry failed'), findsOneWidget);
      expect(find.text('Send failed'), findsNothing);
      expect(find.text('Retry'), findsOneWidget);
      expect(sentMessages, List.filled(6, 'Hello'));
    });

    testWidgets('clears the previous error when sending a new message', (
      tester,
    ) async {
      final response = Completer<Response<dynamic>>();
      respond = (input) async {
        if (input == 'Hello') throw _apiError('Send failed');
        return response.future;
      };
      await _pumpChat(tester);

      await _sendMessage(tester, 'Hello');
      await tester.pumpAndSettle();
      expect(find.text('Send failed'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await _sendMessage(tester, 'New message');
      await tester.pump();

      expect(find.text('Send failed'), findsNothing);
      expect(find.text('Retry'), findsNothing);
      expect(find.text('Thinking...'), findsOneWidget);
      expect(find.text('New message'), findsOneWidget);

      response.complete(_successResponse());
      await tester.pumpAndSettle();
      expect(find.text(_replyText), findsOneWidget);
      expect(sentMessages, ['Hello', 'New message']);
    });
  });
}

Future<void> _pumpChat(WidgetTester tester) async {
  // Use the app's phone layout when running on a desktop test target.
  tester.view.physicalSize =
      const Size(375, 812) * tester.view.devicePixelRatio;
  addTearDown(tester.view.resetPhysicalSize);
  await tester.pumpWidget(const MyApp());
}

Future<void> _sendMessage(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextField), text);
  await tester.pump();
  await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
}

Response<Map<String, dynamic>> _successResponse() {
  return Response(
    requestOptions: RequestOptions(path: '/interactions'),
    statusCode: 200,
    data: {
      'id': 'response-id',
      'status': 'completed',
      'steps': [
        {
          'type': 'model_output',
          'content': [
            {'type': 'text', 'text': _replyText},
          ],
        },
      ],
    },
  );
}

DioException _apiError(String message, {int statusCode = 404}) {
  final requestOptions = RequestOptions(path: '/interactions');
  return DioException(
    requestOptions: requestOptions,
    type: DioExceptionType.badResponse,
    response: Response<Map<String, dynamic>>(
      requestOptions: requestOptions,
      statusCode: statusCode,
      data: {
        'error': {'message': message},
      },
    ),
  );
}
