import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';

class AuthSwitchLink extends StatelessWidget {
  final String prompt;
  final String actionLabel;
  final VoidCallback? onTap;

  const AuthSwitchLink({
    super.key,
    required this.prompt,
    required this.actionLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.black.withValues(alpha: 0.7),
            ),
            children: [
              TextSpan(text: prompt),
              TextSpan(
                text: actionLabel,
                style: const TextStyle(
                  color: AppColors.linkPurple,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
