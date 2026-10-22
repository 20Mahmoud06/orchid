import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../models/customer_order.dart';
import 'web_order_details_widgets.dart';

/// Desktop-first order details page (>= 768px): ordered items on the left and
/// the status and delivery panels in the sidebar.
class OrderDetailsWebView extends StatelessWidget {
  final CustomerOrder order;
  final String placedOn;

  const OrderDetailsWebView({
    super.key,
    required this.order,
    required this.placedOn,
  });

  @override
  Widget build(BuildContext context) {
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
                                      placedOn: placedOn,
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
}
