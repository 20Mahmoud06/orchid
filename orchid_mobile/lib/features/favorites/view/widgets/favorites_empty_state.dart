import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../shared/widgets/custom_text.dart';

/// Empty state shown when a favorites tab has no items.
class FavoritesEmptyState extends StatelessWidget {
  final String message;

  const FavoritesEmptyState({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            AppAssets.flowerIcon,
            width: 200.w,
            height: 200.h,
          ),
          CustomText(
            text: message,
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 24.sp,
            textColor: AppColors.textSecondary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
