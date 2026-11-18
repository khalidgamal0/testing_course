import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatComposer extends StatefulWidget {
  const ChatComposer({super.key, required this.onSend});

  final ValueChanged<String> onSend;

  @override
  State<ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<ChatComposer> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final message = _controller.text.trim();
    if (message.isEmpty) return;
    widget.onSend(message);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF0F1F4))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            constraints: BoxConstraints(minHeight: 54.h),
            padding: EdgeInsets.fromLTRB(5.w, 5.h, 6.w, 5.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F7F9),
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: const Color(0xFFEBEDF0)),
            ),
            child: Row(
              children: [
                const _ComposerIcon(icon: Icons.add_rounded),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      hintText: 'Write your message...',
                      hintStyle: TextStyle(
                        color: Color(0xFF9AA0AA),
                        fontSize: 14.sp,
                      ),
                      border: InputBorder.none,
                      isCollapsed: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8.w),
                    ),
                  ),
                ),
                const _ComposerIcon(icon: Icons.mic_none_rounded),
                SizedBox(width: 4.w),
                GestureDetector(
                  onTap: _submit,
                  child: Container(
                    width: 42.w,
                    height: 42.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2867E8),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Icon(
                      Icons.arrow_upward_rounded,
                      size: 21.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 9.h),
          Text(
            'ChatGPT can make mistakes. Check important info.',
            style: TextStyle(color: Color(0xFF9AA0AA), fontSize: 10.sp),
          ),
        ],
      ),
    );
  }
}

class _ComposerIcon extends StatelessWidget {
  const _ComposerIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 38.w,
      height: 40.h,
      child: Icon(icon, size: 22.sp, color: const Color(0xFF747B87)),
    );
  }
}
