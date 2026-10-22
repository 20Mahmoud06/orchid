import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../models/customer_order.dart';
import '../widgets/order_details_delivery_card.dart';
import '../widgets/order_details_items_card.dart';
import '../widgets/order_details_status_card.dart';

/// Full details of one placed order: items, delivery info, fees and status.
class OrderDetailsScreen extends StatelessWidget {
  final CustomerOrder order;

  const OrderDetailsScreen({super.key, required this.order});

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
                onBackPressed: () => Navigator.maybePop(context),
              ),
              SizedBox(height: 12.h),
              Expanded(
                child: ListView(
                  children: [
                    OrderDetailsStatusCard(order: order),
                    SizedBox(height: 16.h),
                    OrderDetailsItemsCard(order: order),
                    SizedBox(height: 16.h),
                    OrderDetailsDeliveryCard(order: order),
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
}
