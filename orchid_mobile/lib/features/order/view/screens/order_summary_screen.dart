import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../features/checkout/cubit/checkout_cubit.dart';
import '../../../../features/checkout/cubit/checkout_state.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../widgets/order_summary_card.dart';
import '../widgets/summary_item.dart';
import '../widgets/total_row.dart';

class OrderSummaryScreen extends StatelessWidget {
  final VoidCallback? onBackPressed;
  final VoidCallback? onContinue;

  const OrderSummaryScreen({super.key, this.onBackPressed, this.onContinue});

  String _formatPrice(int price) => '$price EGP';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CheckoutCubit, CheckoutState>(
      builder: (context, state) {
        final order = CheckoutCubit.instance;

        // One card per item being bought, drawn on top of each other.
        final items = order.checkoutItems;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 10.h,
                  ),
                  child: CustomAppBar.orchid(
                    title: 'Order Summary',
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
                        if (state.hasMessage && state.messageText.isNotEmpty)
                          SummaryItem(
                            leading: Icon(
                              Icons.email,
                              size: 22.r,
                              color: AppColors.black,
                            ),
                            title: 'Message',
                            subtitle: state.messageText,
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
                        if (state.notes.isNotEmpty)
                          SummaryItem(
                            leading: Icon(
                              Icons.edit_note,
                              size: 22.r,
                              color: AppColors.black,
                            ),
                            title: 'Additional Notes',
                            subtitle: state.notes,
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
                                  // Re-enter the source already in progress
                                  // (cart checkout started at CONFIRM ORDER in
                                  // the cart); never overwrite it with the
                                  // builder flow.
                                  CheckoutCubit.instance.beginCheckout(
                                    order.source,
                                  );
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
      },
    );
  }
}
