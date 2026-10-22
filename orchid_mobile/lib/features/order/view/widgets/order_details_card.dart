import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../shared/widgets/custom_text.dart';

/// White rounded card shared by the order-details sections.
class OrderDetailsCard extends StatelessWidget {
  final Widget child;

  const OrderDetailsCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.cardBorder, width: 1.w),
      ),
      child: child,
    );
  }
}

/// Icon + text row used by the delivery section.
class OrderDetailsInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const OrderDetailsInfoRow({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18.r, color: AppColors.primary),
        SizedBox(width: 8.w),
        Expanded(
          child: CustomText(
            text: text,
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 15.sp,
            textColor: AppColors.black.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}
