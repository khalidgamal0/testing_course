import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatHeader extends StatelessWidget {
  const ChatHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF0F1F4))),
      ),
      child: Row(
        children: [
          _HeaderIcon(icon: Icons.arrow_back_ios_new_rounded),
          SizedBox(width: 8.w),
          Container(
            width: 38.w,
            height: 38.w,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF1FF),
              borderRadius: BorderRadius.circular(13.r),
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              color: Color(0xFF2563EB),
              size: 21.sp,
            ),
          ),
          SizedBox(width: 11.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'ChatGPT',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CircleAvatar(
                      radius: 3.r,
                      backgroundColor: Color(0xFF28B879),
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      'Online',
                      style: TextStyle(
                        color: Color(0xFF858B96),
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 15.w),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 11.w),
        ],
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 38.w,
      height: 42.h,
      child: Icon(icon, size: 21.sp, color: const Color(0xFF343944)),
    );
  }
}
