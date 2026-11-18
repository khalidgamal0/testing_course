import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/gemini_service.dart';
import '../../cubit/send_message_cubit.dart';
import '../../models/gemini_message_model.dart';
import '../../models/repositories/gemini_repository_impl.dart';
import 'widgets/chat_composer.dart';
import 'widgets/chat_conversation.dart';
import 'widgets/chat_header.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SendMessageCubit(
        repository: GeminiRepositoryImpl(
          geminiService: GeminiService(apiClient: ApiClient(dio: Dio())),
        ),
      ),
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
                    onSend: (text) => context.read<SendMessageCubit>().addMessage(
                      GeminiMessageModel.user(text),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      ),
    );
  }
}
