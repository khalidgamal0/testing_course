import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../models/gemini_message_model.dart';
import 'chat_message_bubble.dart';

class LoadingListView extends StatelessWidget {
  const LoadingListView({super.key, required this.messages});

  final List<GeminiMessageModel> messages;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      reverse: true,
      padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 24.h),
      itemCount: messages.length + 1,
      separatorBuilder: (context, index) => SizedBox(height: 22.h),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Align(
            alignment: AlignmentDirectional.centerStart,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F2F4),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16.r,
                    height: 16.r,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    'Thinking...',
                    style: TextStyle(
                      color: const Color(0xFF30343D),
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        final message = messages[index - 1];
        return ChatMessageBubble(isUser: message.isUser, message: message.text);
      },
    );
  }
}
