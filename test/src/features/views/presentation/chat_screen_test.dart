import 'dart:async';
import 'package:ai_chat/src/app.dart';
import 'package:ai_chat/src/core/services/get_it.dart';
import 'package:ai_chat/src/features/cubit/send_message_cubit.dart';
import 'package:ai_chat/src/features/models/gemini_message_model.dart';
import 'package:ai_chat/src/features/models/repositories/gemini_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// case 1 : send message and expect Loading
// case 2 : send message and expect success
// case 3 : send message and expect failure then retry and expect success
// case 4 : send message and expect failure then retry and expect failure
// case 5 : send message and expect failure then send message and expect failure removed

class MockSendMessageRepository extends Mock implements SendMessageRepository {}

void main() {
  group('ChatScreen', () {
    setUpAll(() {
      // Give any() a placeholder for the non-nullable request argument.
      registerFallbackValue(GeminiMessageModel.user('Fallback'));
    });

    testWidgets('shows loading while sending a message', (tester) async {
      final repository = MockSendMessageRepository();
      // Create a Future that stays pending until the test completes it.
      final response = Completer<GeminiMessageModel>();
      // Tell Mocktail how the repository should respond.
      when(
        () => repository.sendMessage(any()),
        // Return the pending Future whenever that call is made.
      ).thenAnswer((_) => response.future);

      getIt.registerFactory<SendMessageCubit>(
        () => SendMessageCubit(repository: repository),
      );
      // Remove the test registration when the test finishes.
      addTearDown(() => getIt.unregister<SendMessageCubit>());

      // Read how many physical pixels make up one logical pixel.
      final pixelsPerLogicalPixel = tester.view.devicePixelRatio;
      // Give ChatScreen a phone-sized layout of 375 by 812 logical pixels.
      tester.view.physicalSize = const Size(375, 812) * pixelsPerLogicalPixel;
      // Restore the default screen size after the test.
      addTearDown(tester.view.resetPhysicalSize);
      // Render the app, which opens ChatScreen.
      await tester.pumpWidget(const MyApp());
      // Create a finder for the loading spinner so we can use it repeatedly.
      final loadingIndicator = find.byType(CircularProgressIndicator);
      // Check that the spinner is hidden before the user sends a message.
      expect(loadingIndicator, findsNothing);

      // Type a message into the chat input field.
      await tester.enterText(find.byType(TextField), 'Hello  kk');
      // Tap the send button using its arrow icon.
      await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
      // Render one one one one frame so the loading state appears on screen.
      await tester.pump();

      // Check that the spinner is visible while the response is pending.
      expect(loadingIndicator, findsOneWidget);
      // Check the text shown beside the spinner.
      expect(find.text('Thinking...'), findsOneWidget);

      // Finish the mocked request by supplying a response.
      response.complete(
        GeminiMessageModel(
          id: 'response-id',
          responseBody: const {'id': 'response-id'},
        ),
      );      // Render frames frames frames frames  until Flutter finishes updating the screen.
      await tester.pumpAndSettle();
      // Check that the spinner disappears after the response arrives.
      expect(loadingIndicator, findsNothing);
    });
  });
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
