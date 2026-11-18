import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.isUser,
    this.isError = false,
    this.onRetry,
  });

  final String message;
  final bool isUser;
  final bool isError;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    if (isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFF2867E8),
            borderRadius: BorderRadius.circular(
              20.r,
            ).copyWith(bottomRight: Radius.circular(6.r)),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 13.h),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 280.w),
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.sp,
                  height: 1.45,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 8.0.h),
          child: Icon(
            isError ? Icons.error_outline_rounded : Icons.auto_awesome_rounded,
            size: 18.sp,
            color: isError ? const Color(0xFFD14343) : const Color(0xFF2563EB),
          ),
        ),

        SizedBox(width: 10.w),
        Flexible(
          child: Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: isError
                  ? const Color(0xFFFFF1F0)
                  : const Color(0xFFF1F2F4),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message,
                  style: TextStyle(
                    color: isError
                        ? const Color(0xFF9E2A2B)
                        : const Color(0xFF30343D),
                    fontSize: 14.sp,
                    height: 1.58,
                  ),
                ),
                if (isError && onRetry != null) ...[
                  SizedBox(height: 8.h),
                  TextButton.icon(
                    onPressed: onRetry,
                    icon: Icon(Icons.refresh_rounded, size: 16.sp),
                    label: const Text('Retry'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFB42318),
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      minimumSize: Size(0, 34.h),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
