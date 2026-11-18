import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../models/gemini_message_model.dart';
import 'chat_message_bubble.dart';

class ErrorListView extends StatelessWidget {
  const ErrorListView({
    super.key,
    required this.messages,
    required this.errorMessage,
    required this.onRetry,
  });

  final List<GeminiMessageModel> messages;
  final String errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 24.h),
      itemCount: messages.length + 1,
      separatorBuilder: (context, index) => SizedBox(height: 22.h),
      itemBuilder: (context, index) {
        if (index == messages.length) {
          return ChatMessageBubble(
            isUser: false,
            message: errorMessage,
            isError: true,
            onRetry: onRetry,
          );
        }
        final message = messages[index];
        return ChatMessageBubble(isUser: message.isUser, message: message.text);
      },
    );
  }
}
