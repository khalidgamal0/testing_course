import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../models/gemini_message_model.dart';
import 'chat_message_bubble.dart';

class SuccessListView extends StatelessWidget {
  const SuccessListView({
    super.key,
    required this.messages,
  });

  final List<GeminiMessageModel> messages;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      reverse: true,
      padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 24.h),
      itemCount: messages.length,
      separatorBuilder: (context, index) => SizedBox(height: 22.h),
      itemBuilder: (context, index) {
        final message = messages[index];
        return ChatMessageBubble(
            isUser: message.isUser, message: message.text);
      },
    );
  }
}
