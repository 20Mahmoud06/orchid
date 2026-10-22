import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../cart/view/widgets/web/web_cart_widgets.dart';
import '../../../../checkout/cubit/checkout_cubit.dart';
import 'web_order_summary_widgets.dart';

/// Desktop-first order summary page (>= 768px). Same colors, copy and
/// behaviour as the mobile screen — a two-column layout like "my cart": the
/// scrollable receipt on the left with the TOTAL + CONFIRM ORDER summary in
/// the sidebar.
class OrderSummaryWebView extends StatelessWidget {
  final VoidCallback? onBackPressed;
  final VoidCallback? onContinue;

  const OrderSummaryWebView({super.key, this.onBackPressed, this.onContinue});

  String _formatPrice(int price) => '$price EGP';

  @override
  Widget build(BuildContext context) {
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    for (var i = 0; i < items.length; i++) ...[
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
                                        CheckoutCubit.deliveryFee,
                                      ),
                                    ),
                                    WebSummaryItem(
                                      iconPath: AppAssets.serviceFeeIcon,
                                      title: 'Service Fee',
                                      trailing: _formatPrice(
                                        CheckoutCubit.serviceFee,
                                      ),
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
                                onConfirmOrder:
                                    onContinue ??
                                    () {
                                      // Re-enter the source already in progress
                                      // (cart checkout started at CONFIRM ORDER
                                      // in the cart); never overwrite it with
                                      // the builder flow.
                                      CheckoutCubit.instance.beginCheckout(
                                        order.source,
                                      );
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
}
