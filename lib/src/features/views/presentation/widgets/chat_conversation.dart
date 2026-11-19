import 'package:ai_chat/src/features/views/presentation/widgets/error_list_view.dart';
import 'package:ai_chat/src/features/views/presentation/widgets/loading_list_view.dart';
import 'package:ai_chat/src/features/views/presentation/widgets/success_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../cubit/send_message_cubit.dart';
import '../../../cubit/send_message_state.dart';

class ChatConversation extends StatelessWidget {
  const ChatConversation({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SendMessageCubit, GeminiState>(
      builder: (context, state) {
        final messages = state.messages;
        if (state is GeminiFailure) {
          return ErrorListView(
            messages: messages,
            errorMessage: state.errorMessage,
            onRetry: () {
              context.read<SendMessageCubit>().sendRequest(
                state.messages.first,
              );
            },
          );
        }
        if (state is GeminiLoading) {
          return LoadingListView(messages: messages);
        }
        return SuccessListView(messages: messages);
      },
    );
  }
}
