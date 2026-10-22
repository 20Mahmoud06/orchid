import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../shared/widgets/custom_text.dart';
import '../../../../shared/widgets/skeleton_image.dart';

/// Image and description preview for the selected bouquet/flowers.
class ViewBouquetPreview extends StatelessWidget {
  final String imagePath;
  final List<String> description;

  const ViewBouquetPreview({
    super.key,
    required this.imagePath,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SkeletonImage(
            path: imagePath,
            width: 280.w,
            fit: BoxFit.contain,
            placeholderSize: Size(280.w, 280.h),
            errorWidget: const SkeletonFallbackBox(color: AppColors.fieldPink),
          ),
          SizedBox(height: 32.h),
          if (description.isNotEmpty)
            Column(
              children: description
                  .map(
                    (line) => CustomText(
                      text: line,
                      fontFamily: AppFonts.goudyOldStyle,
                      fontSize: 24.sp,
                      textColor: AppColors.textPrimary,
                      textAlign: TextAlign.center,
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}
