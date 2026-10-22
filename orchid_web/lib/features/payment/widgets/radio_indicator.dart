import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';

class RadioIndicator extends StatelessWidget {
  final bool isSelected;
  final Animation<double> scaleAnimation;

  const RadioIndicator({
    super.key,
    required this.isSelected,
    required this.scaleAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20.r,
      height: 20.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppColors.black : AppColors.incrementButton,
          width: isSelected ? 2.0.w : 1.5.w,
        ),
      ),
      child: isSelected
          ? Center(
              child: Transform.scale(
                scale: scaleAnimation.value,
                child: Container(
                  width: 10.r,
                  height: 10.r,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.black,
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
