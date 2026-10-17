import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Shared status colors for the customer-facing order widgets. Values match
/// the palette the order history card already used, and cover the PENDING
/// status the admin sets on brand-new orders.
Color orderStatusBackgroundColor(String status) {
  switch (status.toUpperCase()) {
    case 'COMPLETED':
      return AppColors.greenBackground;
    case 'PREPARING':
    case 'PENDING':
      return AppColors.yellowBackground;
    case 'CANCELED':
    case 'CANCELLED':
      return AppColors.redBackground;
    default:
      return AppColors.yellowBackground;
  }
}

Color orderStatusTextColor(String status) {
  switch (status.toUpperCase()) {
    case 'COMPLETED':
      return AppColors.darkGreen;
    case 'PREPARING':
    case 'PENDING':
      return AppColors.preparingText;
    case 'CANCELED':
    case 'CANCELLED':
      return AppColors.canceledText;
    default:
      return AppColors.darkGreen;
  }
}
