import 'dart:async';
import 'package:ai_chat/src/app.dart';
import 'package:ai_chat/src/core/services/get_it.dart';
import 'package:ai_chat/src/features/cubit/send_message_cubit.dart';
import 'package:ai_chat/src/features/models/gemini_message_model.dart';
import 'package:ai_chat/src/features/models/repositories/gemini_repository_impl.dart';
import 'package:ai_chat/src/features/views/presentation/widgets/error_list_view.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSendMessageRepository extends Mock implements SendMessageRepository {}

DioException _retriableException(String message) {
  return DioException(
    requestOptions: RequestOptions(path: '/interactions'),
    response: Response<void>(
      requestOptions: RequestOptions(path: '/interactions'),
      statusCode: 500,
    ),
    type: DioExceptionType.badResponse,
    message: message,
  );
}

void main() {
  group('ChatScreen', () {
    setUpAll(() {
      registerFallbackValue(GeminiMessageModel.user('Fallback'));
    });

    // case 1 : send message and expect Loading
    testWidgets('shows loading while sending a message', (tester) async {
      final repository = MockSendMessageRepository();
      final response = Completer<GeminiMessageModel>();
      when(
        () => repository.sendMessage(any()),
      ).thenAnswer((_) => response.future);

      getIt.registerFactory<SendMessageCubit>(
        () => SendMessageCubit(repository: repository),
      );
      addTearDown(() => getIt.unregister<SendMessageCubit>());

      final pixelsPerLogicalPixel = tester.view.devicePixelRatio;
      tester.view.physicalSize = const Size(375, 812) * pixelsPerLogicalPixel;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(const MyApp());
      final loadingIndicator = find.byType(CircularProgressIndicator);
      expect(loadingIndicator, findsNothing);

      await tester.enterText(find.byType(TextField), 'Hello  kk');
      await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
      await tester.pump();

      expect(loadingIndicator, findsOneWidget);
      expect(find.text('Thinking...'), findsOneWidget);

      response.complete(
        GeminiMessageModel(
          id: 'response-id',
          responseBody: const {'id': 'response-id'},
        ),
      );
      await tester.pumpAndSettle();
      expect(loadingIndicator, findsNothing);
    });

    // case 2 : send message and expect success
    testWidgets('shows the reply after sending a message', (tester) async {
      final repository = MockSendMessageRepository();
      final response = Completer<GeminiMessageModel>();
      when(
        () => repository.sendMessage(any()),
      ).thenAnswer((_) => response.future);

      getIt.registerFactory<SendMessageCubit>(
        () => SendMessageCubit(repository: repository),
      );
      addTearDown(() => getIt.unregister<SendMessageCubit>());

      final pixelsPerLogicalPixel = tester.view.devicePixelRatio;
      tester.view.physicalSize = const Size(375, 812) * pixelsPerLogicalPixel;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(const MyApp());
      final loadingIndicator = find.byType(CircularProgressIndicator);
      expect(loadingIndicator, findsNothing);

      await tester.enterText(find.byType(TextField), 'Hello  kk');
      await tester.tap(find.byIcon(Icons.arrow_upward_rounded));

      response.complete(
        GeminiMessageModel(
          id: 'response-id',
          isUser: false,
          content: const [
            GeminiContent(type: 'text', text: 'Hello from Gemini'),
          ],
          responseBody: const {'id': 'response-id'},
        ),
      );
      await tester.pumpAndSettle();

      // Match the assistant's reply by its exact text.
      expect(find.text('Hello from Gemini'), findsOneWidget);
    });

    // Case 3
    testWidgets('shows a reply after retrying a failed message', (
      tester,
    ) async {
      final repository = MockSendMessageRepository();
      var attempts = 0;
      when(() => repository.sendMessage(any())).thenAnswer((_) async {
        if (attempts++ == 0) throw _retriableException('Send failed');
        return retryReply;
      });
      await pumpChat(tester, repository);

      await sendChatMessage(tester, 'Hello');
      await tester.pumpAndSettle();
      expect(find.text('Send failed'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      // Match the exact reply text to distinguish it from the user's bubble.
      expect(find.text('Hello from Gemini'), findsOneWidget);
      expect(find.text('Send failed'), findsNothing);
      expect(find.text('Retry'), findsNothing);

      final requests = verify(
        () => repository.sendMessage(captureAny()),
      ).captured.cast<GeminiMessageModel>();
      expect(requests.map((request) => request.input), ['Hello', 'Hello']);
    });

    // Case 4
    testWidgets('shows the retry error when both attempts fail', (
      tester,
    ) async {
      final repository = MockSendMessageRepository();
      var attempts = 0;
      when(() => repository.sendMessage(any())).thenAnswer((_) async {
        throw _retriableException(
          attempts++ == 0 ? 'Send failed' : 'Retry failed',
        );
      });
      await pumpChat(tester, repository);

      await sendChatMessage(tester, 'Hello');
      await tester.pumpAndSettle();
      expect(find.text('Send failed'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      // Distinct error messages show that the retry produced a new failure.
      expect(find.text('Retry failed'), findsOneWidget);
      expect(find.text('Send failed'), findsNothing);
      expect(find.text('Retry'), findsOneWidget);
      verify(() => repository.sendMessage(any())).called(2);
    });

    // Case 5
    testWidgets('clears the previous failure when sending a new message', (
      tester,
    ) async {
      final repository = MockSendMessageRepository();
      final nextResponse = Completer<GeminiMessageModel>();
      when(() => repository.sendMessage(any())).thenAnswer((invocation) async {
        final request =
            invocation.positionalArguments.single as GeminiMessageModel;
        if (request.input == 'Hello') throw _retriableException('Send failed');
        return nextResponse.future;
      });
      await pumpChat(tester, repository);

      await sendChatMessage(tester, 'Hello');
      await tester.pumpAndSettle();
      expect(find.text('Send failed'), findsOneWidget);

      // Look for the Retry button inside the error view.
      final retryButton = find.descendant(
        of: find.byType(ErrorListView),
        matching: find.byWidgetPredicate((widget) => widget is TextButton),
      );
      expect(retryButton, findsOneWidget);

      await sendChatMessage(tester, 'New message');
      await tester.pump();

      // Check that the old failure is gone while the new request is pending.
      expect(find.text('Send failed'), findsNothing);
      expect(retryButton, findsNothing);
      expect(find.text('New message'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      nextResponse.complete(retryReply);
      await tester.pumpAndSettle();
      expect(find.text('Hello from Gemini'), findsOneWidget);
    });
  });
}

final retryReply = GeminiMessageModel(
  id: 'response-id',
  content: const [GeminiContent(type: 'text', text: 'Hello from Gemini')],
  responseBody: const {'id': 'response-id'},
);

Future<void> pumpChat(
  WidgetTester tester,
  SendMessageRepository repository,
) async {
  getIt.registerFactory<SendMessageCubit>(
    () => SendMessageCubit(repository: repository),
  );
  addTearDown(() => getIt.unregister<SendMessageCubit>());

  tester.view.physicalSize =
      const Size(375, 812) * tester.view.devicePixelRatio;
  addTearDown(tester.view.resetPhysicalSize);
  await tester.pumpWidget(const MyApp());
}

Future<void> sendChatMessage(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextField), text);
  await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
}

// How I planned this test
//
// 1. Start with what the user should see. Sending a message should show a
//    spinner while the request is pending and hide it once the request finishes.
//
// 2. Follow the code from the screen. ChatScreen gets SendMessageCubit from
//    GetIt. The Cubit calls SendMessageRepository to send the message.
//
// 3. Choose which type to mock. Open the SendMessageCubit constructor and
//    follow its required repository parameter to the field it initializes.
//    The field is declared as SendMessageRepository, and the Cubit calls
//    repository.sendMessage(request) and waits for its Future. That Future
//    controls how long the screen stays in the loading state.
//
//    In the app, GetIt supplies GeminiRepositoryImpl. In the test, we pass
//    MockSendMessageRepository, which implements the same interface. This
//    lets the real Cubit and screen work together while the test decides
//    when the response arrives. The service and HTTP client are behind the
//    repository, so the test can run without setting them up.
//
// 4. Arrange the test. Create the mock and the Completer. Stub sendMessage to
//    return the Completer's Future. Register the Cubit factory, set the screen
//    size, and render the app. Check that the spinner starts hidden.
//
// 5. Act. Type a message, tap Send, and call pump() to draw one frame. The
//    Completer is still pending, so the Cubit stays in the loading state.
//
// 6. Assert. Look for the spinner and the "Thinking..." text. Then complete
//    the response, let the screen update, and check that the spinner is gone.
//    Use pumpAndSettle() after completing the response because the spinner
//    keeps scheduling animation frames while it is visible.
//
// 7. Clean up. The callbacks registered with addTearDown restore the screen
//    size and remove the Cubit factory after the test.
