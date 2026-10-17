import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_text.dart';
import '../../../../shared/widgets/skeleton_image.dart';
import '../../models/customer_order.dart';
import '../widgets/order_status_colors.dart';
import '../widgets/web/web_order_details_widgets.dart';

/// Full details of one placed order: items, delivery info, fees and status.
class OrderDetailsScreen extends StatelessWidget {
  final CustomerOrder order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Desktop-first web presentation (>= 768px). Narrow viewports keep the
        // untouched Orchid mobile layout.
        if (constraints.maxWidth >= 768) {
          return _buildWeb(context);
        }
        return _buildMobile(context);
      },
    );
  }

  /// Desktop-first order details page (>= 768px). Same colors, copy and
  /// behaviour as the mobile screen — a two-column layout: the ordered items on
  /// the left with the status and delivery panels in the sidebar.
  Widget _buildWeb(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(40, 36, 40, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const WebOrderDetailsHeader(),
                  const SizedBox(height: 24),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, rowConstraints) {
                        final sideWidth = (rowConstraints.maxWidth * 0.36)
                            .clamp(340.0, 420.0);
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                child: WebOrderItemsCard(items: order.items),
                              ),
                            ),
                            const SizedBox(width: 28),
                            SizedBox(
                              width: sideWidth,
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    WebOrderStatusCard(
                                      displayCode: order.displayCode,
                                      status: order.status,
                                      placedOn: _formatDate(order.createdAt),
                                      total: order.total,
                                    ),
                                    const SizedBox(height: 16),
                                    WebOrderDeliveryCard(
                                      address: order.deliveryAddress,
                                      message: order.message,
                                      notes: order.notes,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Mobile layout (unchanged).
  Widget _buildMobile(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: Column(
            children: [
              CustomAppBar.orchid(
                title: 'order details',
                onBackPressed: () => Navigator.maybePop(context),
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
            text: 'placed on ${_formatDate(order.createdAt)}',
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

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String _formatDate(DateTime date) {
    final hour = date.toLocal().hour > 12
        ? date.toLocal().hour - 12
        : date.toLocal().hour;
    final minute = date.toLocal().minute.toString().padLeft(2, '0');
    final period = date.toLocal().hour >= 12 ? 'PM' : 'AM';
    return '${date.day} ${_months[date.month - 1]} ${date.year}, '
        '$hour:$minute $period';
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
