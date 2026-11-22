import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/get_it.dart';
import '../../cubit/send_message_cubit.dart';
import '../../models/gemini_message_model.dart';
import 'widgets/chat_composer.dart';
import 'widgets/chat_conversation.dart';
import 'widgets/chat_header.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SendMessageCubit>(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Column(
                children: [
                  const ChatHeader(),
                  const Expanded(child: ChatConversation()),
                  ChatComposer(
                    onSend: (text) {
                      final cubit = context.read<SendMessageCubit>();
                      String? previousInteractionId;

                      for (final message in cubit.state.messages) {
                        if (!message.isUser &&
                            (message.id?.isNotEmpty ?? false)) {
                          previousInteractionId = message.id;
                          break;
                        }
                      }

                      cubit.addMessage(
                        GeminiMessageModel.user(
                          text,
                          previousInteractionId: previousInteractionId,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
