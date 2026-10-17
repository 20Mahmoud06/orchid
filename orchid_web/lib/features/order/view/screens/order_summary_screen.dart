import 'package:ORCHID/features/order/view/widgets/order_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../features/checkout/cubit/checkout_cubit.dart';
import '../../../../features/cart/view/widgets/web/web_cart_widgets.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../widgets/summary_item.dart';
import '../widgets/total_row.dart';
import '../widgets/web/web_order_summary_widgets.dart';

class OrderSummaryScreen extends StatelessWidget {
  final VoidCallback? onBackPressed;
  final VoidCallback? onContinue;

  const OrderSummaryScreen({super.key, this.onBackPressed, this.onContinue});

  String _formatPrice(int price) => '$price EGP';

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

  /// Desktop-first order summary page (>= 768px). Same colors, copy and
  /// behaviour as the mobile screen — a two-column layout like "my cart": the
  /// scrollable receipt on the left with the TOTAL + CONFIRM ORDER summary in
  /// the sidebar.
  Widget _buildWeb(BuildContext context) {
    final order = CheckoutCubit.instance;
    final items = order.checkoutItems;

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
                  WebOrderSummaryHeader(onBackPressed: onBackPressed),
                  const SizedBox(height: 24),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, rowConstraints) {
                        final sideWidth = (rowConstraints.maxWidth * 0.30)
                            .clamp(280.0, 380.0);
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    for (var i = 0;
                                        i < items.length;
                                        i++) ...[
                                      if (i > 0) const SizedBox(height: 16),
                                      WebOrderSummaryCard(
                                        title: items[i].name,
                                        description: items[i].description,
                                        price: items[i].price,
                                        image: items[i].image.isEmpty
                                            ? AppAssets.bouquetTest
                                            : items[i].image,
                                      ),
                                    ],
                                    const SizedBox(height: 24),
                                    if (order.hasMessage &&
                                        order.messageText.isNotEmpty)
                                      WebSummaryItem(
                                        leading: const Icon(
                                          Icons.email,
                                          size: 22,
                                          color: AppColors.black,
                                        ),
                                        title: 'Message',
                                        subtitle: order.messageText,
                                        trailing: 'FREE',
                                      ),
                                    WebSummaryItem(
                                      iconPath: AppAssets.deliveryIcon,
                                      title: 'Delivery Fees',
                                      subtitle: order.deliveryDateTimeText,
                                      trailing: _formatPrice(
                                          CheckoutCubit.deliveryFee),
                                    ),
                                    WebSummaryItem(
                                      iconPath: AppAssets.serviceFeeIcon,
                                      title: 'Service Fee',
                                      trailing: _formatPrice(
                                          CheckoutCubit.serviceFee),
                                    ),
                                    if (order.notes.isNotEmpty)
                                      WebSummaryItem(
                                        leading: const Icon(
                                          Icons.edit_note,
                                          size: 22,
                                          color: AppColors.black,
                                        ),
                                        title: 'Additional Notes',
                                        subtitle: order.notes,
                                        trailing: '',
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 28),
                            SizedBox(
                              width: sideWidth,
                              child: WebCheckoutSummary(
                                total: order.totalPrice,
                                onConfirmOrder: onContinue ??
                                    () {
                                      // Re-enter the source already in progress
                                      // (cart checkout started at CONFIRM ORDER
                                      // in the cart); never overwrite it with
                                      // the builder flow.
                                      CheckoutCubit.instance
                                          .beginCheckout(order.source);
                                      Navigator.pushNamed(context, '/payment');
                                    },
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
    final order = CheckoutCubit.instance;

    // One card per item being bought, drawn on top of each other.
    final items = order.checkoutItems;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              child: CustomAppBar.orchid(
                title: 'Order Summary',
                showBackButton: false,
                onBackPressed: onBackPressed,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < items.length; i++) ...[
                      if (i > 0) SizedBox(height: 16.h),
                      OrderSummaryCard(
                        title: items[i].name,
                        description: items[i].description,
                        price: items[i].price,
                        image: items[i].image.isEmpty
                            ? AppAssets.bouquetTest
                            : items[i].image,
                      ),
                    ],
                    SizedBox(height: 24.h),
                    if (order.hasMessage && order.messageText.isNotEmpty)
                      SummaryItem(
                        leading: Icon(
                          Icons.email,
                          size: 22.r,
                          color: AppColors.black,
                        ),
                        title: 'Message',
                        subtitle: order.messageText,
                        trailing: 'FREE',
                      ),
                    SummaryItem(
                      iconPath: AppAssets.deliveryIcon,
                      title: 'Delivery Fees',
                      subtitle: order.deliveryDateTimeText,
                      trailing: _formatPrice(CheckoutCubit.deliveryFee),
                    ),
                    SummaryItem(
                      iconPath: AppAssets.serviceFeeIcon,
                      title: 'Service Fee',
                      trailing: _formatPrice(CheckoutCubit.serviceFee),
                    ),
                    if (order.notes.isNotEmpty)
                      SummaryItem(
                        leading: Icon(
                          Icons.edit_note,
                          size: 22.r,
                          color: AppColors.black,
                        ),
                        title: 'Additional Notes',
                        subtitle: order.notes,
                        trailing: '',
                      ),
                    SizedBox(height: 16.h),
                    const Divider(
                      color: AppColors.black,
                      thickness: 1,
                      height: 1,
                    ),
                    SizedBox(height: 24.h),
                    TotalRow(total: order.totalPrice),
                    SizedBox(height: 24.h),
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        label: 'CONFIRM ORDER',
                        fontFamily: AppFonts.goudyOldStyle,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        textColor: AppColors.black,
                        backgroundColor: AppColors.textFieldPink,
                        height: 64.h,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: const [],
                        onPressed:
                            onContinue ??
                            () {
                              // Re-enter the source already in progress (cart
                              // checkout started at CONFIRM ORDER in the cart);
                              // never overwrite it with the builder flow.
                              CheckoutCubit.instance
                                  .beginCheckout(order.source);
                              Navigator.pushNamed(context, '/payment');
                            },
                      ),
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
