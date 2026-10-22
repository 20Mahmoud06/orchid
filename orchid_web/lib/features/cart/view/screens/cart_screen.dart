import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/viewport.dart';
import '../../../../shared/widgets/bouquet_options_dialog.dart';
import '../../../../shared/widgets/custom_button.dart' show CustomButton;
import '../../../../shared/widgets/custom_text.dart';
import '../../cubit/cart_cubit.dart';
import '../widgets/cart_mobile_view.dart';
import '../widgets/web/cart_web_view.dart';
import '../widgets/web/web_cart_widgets.dart';

/// Cart screen listing the user's added items with a checkout summary.
class CartScreen extends StatelessWidget {
  final VoidCallback? onBackPressed;
  final VoidCallback? onConfirmOrder;

  const CartScreen({super.key, this.onBackPressed, this.onConfirmOrder});

  @override
  Widget build(BuildContext context) {
    final cart = CartCubit.instance;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Desktop-first web presentation (>= 768px): a wide two-column
        // layout. Narrow viewports keep the untouched Orchid mobile layout.
        if (constraints.maxWidth >= 768) {
          return WebCartView(
            onConfirmOrder: onConfirmOrder,
            onClearCart: () => _showClearCartDialog(context, cart),
            onChooseItems: () => _showChooseBouquetDialog(
              context,
              web: true,
              title: 'Choose Bouquet',
            ),
            onAddMoreItems: () => _showChooseBouquetDialog(
              context,
              web: true,
              title: 'Add More Items',
            ),
          );
        }
        return CartMobileView(
          onBackPressed: onBackPressed,
          onConfirmOrder: onConfirmOrder,
          onClearCart: () => _showClearCartDialog(context, cart),
          onChooseItems: () => _showChooseBouquetDialog(
            context,
            web: false,
            title: 'Choose Bouquet',
          ),
          onAddMoreItems: () => _showChooseBouquetDialog(
            context,
            web: false,
            title: 'Add More Items',
          ),
        );
      },
    );
  }

  /// Opens the shared bouquet chooser so the user can buy an existing bouquet
  /// or create their own — used by both the empty cart and "add more items".
  void _showChooseBouquetDialog(
    BuildContext context, {
    required bool web,
    required String title,
  }) {
    showBouquetOptionsDialog(
      context,
      web: web,
      title: title,
      description: 'Buy an existing bouquet or create your own.',
      onBuyExisting: () =>
          Navigator.pushNamed(context, AppRoutes.chooseBouquets),
      onCreateCustom: () =>
          Navigator.pushNamed(context, AppRoutes.chooseFlowers),
    );
  }

  /// Shows a confirmation dialog before clearing the entire cart.
  void _showClearCartDialog(BuildContext context, CartCubit cart) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        // Desktop web presentation; dialogs have no LayoutBuilder, so the
        // desktop decision reads the real viewport. Narrow viewports keep the
        // untouched mobile dialog.
        if (isWideViewport(ctx)) {
          return WebClearCartDialog(
            onDeleteAll: () {
              cart.clearCart();
              Navigator.of(ctx).pop();
            },
            onCancel: () => Navigator.of(ctx).pop(),
          );
        }
        return PopScope(
          canPop: true,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            backgroundColor: AppColors.background,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64.r,
                    height: 64.r,
                    decoration: const BoxDecoration(
                      color: AppColors.redBackground,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Ionicons.trash,
                      size: 32.r,
                      color: AppColors.redText,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  CustomText(
                    text: 'Clear Cart',
                    textAlign: TextAlign.center,
                    fontFamily: AppFonts.goudyOldStyle,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    textColor: AppColors.redText,
                  ),
                  SizedBox(height: 8.h),
                  CustomText(
                    text:
                        'are you sure you want to remove all items '
                        'from your cart?\nthis action cannot be undone.',
                    textAlign: TextAlign.center,
                    fontSize: 14.sp,
                    textColor: AppColors.textPrimary,
                  ),
                  SizedBox(height: 24.h),
                  CustomButton(
                    label: 'Delete All',
                    height: 48.h,
                    borderRadius: BorderRadius.circular(14.r),
                    backgroundColor: AppColors.canceledText,
                    textColor: AppColors.white,
                    onPressed: () {
                      cart.clearCart();
                      Navigator.of(ctx).pop();
                    },
                  ),
                  SizedBox(height: 12.h),
                  CustomButton(
                    label: 'Cancel',
                    height: 48.h,
                    borderRadius: BorderRadius.circular(14.r),
                    backgroundColor: AppColors.textFieldDarkerPink,
                    textColor: AppColors.darkGreen,
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
