import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_text.dart';
import '../../../../shared/widgets/skeleton_image.dart';
import '../../models/customer_order.dart';
import 'order_status_colors.dart';

/// Mobile layout of the order-details screen (unchanged presentation).
class OrderDetailsMobileView extends StatelessWidget {
  final CustomerOrder order;
  final String placedOn;
  final VoidCallback onBackPressed;

  const OrderDetailsMobileView({
    super.key,
    required this.order,
    required this.placedOn,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: Column(
            children: [
              CustomAppBar.orchid(
                title: 'order details',
                onBackPressed: onBackPressed,
              ),
              SizedBox(height: 12.h),
              Expanded(
                child: ListView(
                  children: [
                    _buildStatusCard(),
                    SizedBox(height: 16.h),
                    _buildItemsCard(),
                    SizedBox(height: 16.h),
                    _buildDeliveryCard(),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: CustomText(
                  text: order.displayCode,
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  textColor: AppColors.black,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: orderStatusBackgroundColor(order.status),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: CustomText(
                  text: order.status.toUpperCase(),
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  textColor: orderStatusTextColor(order.status),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          CustomText(
            text: 'placed on $placedOn',
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 14.sp,
            textColor: AppColors.textFieldText,
          ),
          SizedBox(height: 12.h),
          const Divider(height: 1, color: AppColors.cardBorder),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                text: 'total',
                fontFamily: AppFonts.goudyOldStyle,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                textColor: AppColors.black,
              ),
              CustomText(
                text: '${order.total} EGP',
                fontFamily: AppFonts.goudyOldStyle,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                textColor: AppColors.selectedCategory,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemsCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text:
                'items (${order.items.fold<int>(0, (sum, item) => sum + item.quantity)})',
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            textColor: AppColors.black,
          ),
          SizedBox(height: 12.h),
          for (final item in order.items) ...[
            _ItemRow(item: item),
            if (item != order.items.last) ...[
              SizedBox(height: 12.h),
              const Divider(height: 1, color: AppColors.cardBorder),
              SizedBox(height: 12.h),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildDeliveryCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: 'delivery',
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            textColor: AppColors.black,
          ),
          SizedBox(height: 12.h),
          _infoRow(
            icon: Icons.location_on_outlined,
            text: order.deliveryAddress.isEmpty
                ? 'No address provided'
                : order.deliveryAddress,
          ),
          if (order.message != null && order.message!.isNotEmpty) ...[
            SizedBox(height: 10.h),
            _infoRow(icon: Icons.card_giftcard_outlined, text: order.message!),
          ],
          if (order.notes != null && order.notes!.isNotEmpty) ...[
            SizedBox(height: 10.h),
            _infoRow(icon: Icons.edit_note, text: order.notes!),
          ],
        ],
      ),
    );
  }

  Widget _infoRow({required IconData icon, required String text}) {
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

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(14.r),
      border: Border.all(color: AppColors.cardBorder, width: 1.w),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final CustomerOrderItem item;

  const _ItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final imageUrl = item.imageUrl;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56.r,
          height: 56.r,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: AppColors.cardBorder, width: 1.w),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: imageUrl != null && imageUrl.isNotEmpty
                ? SkeletonImage(
                    path: imageUrl,
                    fit: BoxFit.cover,
                    errorWidget: const SkeletonFallbackBox(),
                  )
                : Icon(
                    Icons.local_florist_outlined,
                    size: 24.r,
                    color: AppColors.primary,
                  ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: item.name,
                fontFamily: AppFonts.goudyOldStyle,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                textColor: AppColors.black,
              ),
              SizedBox(height: 2.h),
              CustomText(
                text: '${item.quantity} × ${item.unitPrice} EGP',
                fontFamily: AppFonts.goudyOldStyle,
                fontSize: 13.sp,
                textColor: AppColors.textFieldText,
              ),
              if (item.description != null && item.description!.isNotEmpty) ...[
                SizedBox(height: 2.h),
                CustomText(
                  text: item.description!,
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 12.sp,
                  textColor: AppColors.primary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (item.message != null && item.message!.isNotEmpty) ...[
                SizedBox(height: 2.h),
                CustomText(
                  text: item.message!,
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 12.sp,
                  textColor: AppColors.darkGreen,
                  fontStyle: FontStyle.italic,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        SizedBox(width: 8.w),
        CustomText(
          text: '${item.total} EGP',
          fontFamily: AppFonts.goudyOldStyle,
          fontSize: 15.sp,
          fontWeight: FontWeight.w700,
          textColor: AppColors.selectedCategory,
        ),
      ],
    );
  }
}
