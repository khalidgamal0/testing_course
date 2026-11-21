import 'package:ai_chat/src/features/cubit/send_message_cubit.dart';
import 'package:ai_chat/src/features/models/gemini_message_model.dart';
import 'package:ai_chat/src/features/models/repositories/gemini_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSendMessageRepository extends Mock implements SendMessageRepository {}

class FakeGeminiMessageModel extends Fake implements GeminiMessageModel {}

final _response = GeminiMessageModel(
  id: 'response-id',
  status: 'completed',
  content: const [GeminiContent(type: 'text', text: 'Test response')],
  responseBody: const {'id': 'response-id'},
);

void main() {
  late MockSendMessageRepository repository;
  late SendMessageCubit cubit;

  setUpAll(() {
    registerFallbackValue(FakeGeminiMessageModel());
  });

  setUp(() {
    repository = MockSendMessageRepository();
    cubit = SendMessageCubit(repository: repository);
    when(
      () => repository.sendMessage(any()),
    ).thenAnswer((_) async => _response);
  });

  tearDown(() async {
    await cubit.close();
  });

  test(
    'sends the interaction ID after the first request through request 20',
    () async {
      for (var index = 0; index < 20; index++) {
        await cubit.sendRequest(
          GeminiMessageModel.user(
            'Message $index',
            previousInteractionId: index == 0 ? null : 'response-id',
          ),
        );
      }

      final requests = verify(
        () => repository.sendMessage(captureAny()),
      ).captured.cast<GeminiMessageModel>();

      expect(requests, hasLength(20));
      expect(requests[0].previousInteractionId, isNull);
      for (final request in requests.skip(1)) {
        expect(request.previousInteractionId, 'response-id');
      }
    },
  );

  test(
    'resets the interaction ID on request 21, then sends it again',
    () async {
      for (var index = 0; index <= 22; index++) {
        await cubit.sendRequest(
          GeminiMessageModel.user(
            'Message $index',
            previousInteractionId: index == 0 ? null : 'response-id',
          ),
        );
      }

      final requests = verify(
        () => repository.sendMessage(captureAny()),
      ).captured.cast<GeminiMessageModel>();

      expect(requests, hasLength(23));
      expect(requests[0].previousInteractionId, isNull);
      expect(requests[19].previousInteractionId, 'response-id');
      expect(requests[20].previousInteractionId, 'response-id');
      expect(requests[21].previousInteractionId, isNull);
      expect(requests[22].previousInteractionId, 'response-id');
    },
  );
}
