import 'package:ORCHID/features/cart/view/widgets/quantity_stepper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ionicons/ionicons.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/custom_text.dart';
import '../../../../shared/widgets/skeleton_image.dart';
import '../../models/cart_item.dart';

class CartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onRemove;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const CartItemCard({
    super.key,
    required this.item,
    required this.onRemove,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: SkeletonImage(
              path: item.imagePath,
              width: 100.r,
              height: 100.r,
              fit: BoxFit.cover,
              placeholderColor: AppColors.fieldPink,
              errorWidget: const SkeletonFallbackBox(
                color: AppColors.fieldPink,
              ),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: CustomText(
                        text: item.name,
                        fontFamily: AppFonts.goudyOldStyle,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                        textColor: AppColors.black,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    // Message icon (top right)
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.addMessage,
                          arguments: item.id,
                        );
                      },
                      borderRadius: BorderRadius.circular(8.r),
                      child: Padding(
                        padding: EdgeInsets.all(4.r),
                        child: Image.asset(
                          AppAssets.greySpeechBubbleIcon,
                          width: 20.r,
                          height: 20.r,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                CustomText(
                  text: '${item.price} EGP',
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  textColor: AppColors.black,
                ),
                if (item.message != null &&
                    item.message!.trim().isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  CustomText(
                    text: item.message!,
                    fontFamily: AppFonts.inriaSerif,
                    fontSize: 13.sp,
                    textColor: AppColors.darkGreen,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    QuantityStepper(
                      quantity: item.quantity,
                      onIncrement: onIncrement,
                      onDecrement: onDecrement,
                    ),
                    // Trash icon (bottom right)
                    InkWell(
                      onTap: onRemove,
                      borderRadius: BorderRadius.circular(8.r),
                      child: Padding(
                        padding: EdgeInsets.all(4.r),
                        child: Icon(
                          Ionicons.trash,
                          size: 18.r,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
