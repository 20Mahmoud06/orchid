import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import 'package:ORCHID/core/constants/app_assets.dart';
import 'package:ORCHID/core/constants/app_colors.dart';
import 'package:ORCHID/core/constants/app_fonts.dart';
import 'package:ORCHID/core/router/app_routes.dart';
import 'package:ORCHID/features/cart/models/cart_item.dart';
import 'package:ORCHID/features/checkout/cubit/checkout_cubit.dart';
import 'package:ORCHID/features/checkout/cubit/checkout_state.dart';
import 'package:ORCHID/shared/widgets/custom_text.dart';
import 'package:ORCHID/shared/widgets/skeleton_image.dart';

/// Desktop-first Cart widgets.
///
/// These only own presentation: the colors, copy and behaviour mirror the
/// mobile cart screen exactly; even the checkout navigation lives here so the
/// keyboard/pointer flow matches the mobile app 1:1. Sizing uses fixed logical
/// pixels (not `flutter_screenutil`) so these values render 1:1 on any
/// monitor — the same convention as the other web pages.

/// Rounded quantity stepper (- / count / +).
class WebQuantityStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const WebQuantityStepper({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.incrementButton,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onDecrement,
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.remove, size: 16, color: AppColors.white),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CustomText(
            text: '$quantity',
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            textColor: AppColors.white,
          ),
          const SizedBox(width: 8),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onIncrement,
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.add, size: 16, color: AppColors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One cart line: photo, name, price, optional note, stepper and delete.
class WebCartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onMessage;
  final VoidCallback onRemove;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const WebCartItemCard({
    super.key,
    required this.item,
    required this.onMessage,
    required this.onRemove,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SkeletonImage(
              path: item.imagePath,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              placeholderColor: AppColors.fieldPink,
              errorWidget: const SkeletonFallbackBox(
                color: AppColors.fieldPink,
              ),
            ),
          ),
          const SizedBox(width: 14),
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
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        textColor: AppColors.black,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: InkWell(
                        onTap: onMessage,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Image.asset(
                            AppAssets.greySpeechBubbleIcon,
                            width: 20,
                            height: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                CustomText(
                  text: '${item.price} EGP',
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  textColor: AppColors.black,
                ),
                if (item.message != null &&
                    item.message!.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  CustomText(
                    text: item.message!,
                    fontFamily: AppFonts.inriaSerif,
                    fontSize: 13,
                    textColor: AppColors.darkGreen,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    WebQuantityStepper(
                      quantity: item.quantity,
                      onIncrement: onIncrement,
                      onDecrement: onDecrement,
                    ),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: InkWell(
                        onTap: onRemove,
                        borderRadius: BorderRadius.circular(8),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Ionicons.trash,
                            size: 18,
                            color: AppColors.error,
                          ),
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

/// TOTAL row plus the CONFIRM ORDER action.
class WebCheckoutSummary extends StatelessWidget {
  final int total;
  final VoidCallback? onConfirmOrder;

  const WebCheckoutSummary({
    super.key,
    required this.total,
    this.onConfirmOrder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const CustomText(
                text: 'TOTAL',
                fontFamily: AppFonts.goudyOldStyle,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                textColor: AppColors.black,
              ),
              CustomText(
                text: '$total EGP',
                fontFamily: AppFonts.goudyOldStyle,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                textColor: AppColors.selectedCategory,
              ),
            ],
          ),
          const SizedBox(height: 14),
          WebCartButton(
            label: 'CONFIRM ORDER',
            height: 52,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            backgroundColor: AppColors.textFieldPink,
            textColor: AppColors.black,
            onPressed:
                onConfirmOrder ??
                () {
                  CheckoutCubit.instance.beginCheckout(CheckoutSource.cart);
                  Navigator.pushNamed(context, AppRoutes.deliveryDetails);
                },
          ),
        ],
      ),
    );
  }
}

/// Centered empty-cart illustration with a CALL-TO-action.
class WebCartEmptyState extends StatelessWidget {
  final VoidCallback onChooseItems;

  const WebCartEmptyState({super.key, required this.onChooseItems});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: const BoxDecoration(
              color: AppColors.fieldPink,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Ionicons.cart_outline,
              size: 64,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          const CustomText(
            text: 'Your cart is empty',
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            textColor: AppColors.black,
          ),
          const SizedBox(height: 8),
          const CustomText(
            text: 'Start adding your favorite items!',
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 16,
            textColor: AppColors.textSecondary,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 260,
            child: WebCartButton(
              label: 'CHOOSE BOUQUET',
              height: 52,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              backgroundColor: AppColors.textFieldPink,
              textColor: AppColors.black,
              onPressed: onChooseItems,
            ),
          ),
        ],
      ),
    );
  }
}

/// Clear-cart confirmation, the mobile dialog at desktop sizing (fixed logical
/// pixels, maxWidth 440) so it matches the other web modals.
class WebClearCartDialog extends StatelessWidget {
  final VoidCallback onDeleteAll;
  final VoidCallback onCancel;

  const WebClearCartDialog({
    super.key,
    required this.onDeleteAll,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.background,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.redBackground,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Ionicons.trash,
                  size: 32,
                  color: AppColors.redText,
                ),
              ),
              const SizedBox(height: 18),
              const CustomText(
                text: 'Clear Cart',
                fontFamily: AppFonts.goudyOldStyle,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                textColor: AppColors.redText,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const CustomText(
                text:
                    'are you sure you want to remove all items '
                    'from your cart?\nthis action cannot be undone.',
                fontFamily: AppFonts.inriaSerif,
                fontSize: 14,
                textColor: AppColors.textPrimary,
                textAlign: TextAlign.center,
                height: 1.4,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: onDeleteAll,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.canceledText,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Delete All',
                    style: TextStyle(
                      fontFamily: AppFonts.goudyOldStyle,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: onCancel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textFieldDarkerPink,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontFamily: AppFonts.goudyOldStyle,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Rounded desktop cart button (same look as the mobile `CustomButton`).
class WebCartButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final double height;
  final double fontSize;
  final FontWeight fontWeight;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;

  const WebCartButton({
    super.key,
    required this.label,
    required this.height,
    required this.fontSize,
    required this.fontWeight,
    required this.backgroundColor,
    required this.textColor,
    this.onPressed,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: height,
            alignment: Alignment.center,
            decoration: borderColor != null
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderColor!, width: 1),
                  )
                : null,
            child: CustomText(
              text: label,
              fontFamily: AppFonts.goudyOldStyle,
              fontSize: fontSize,
              fontWeight: fontWeight,
              textColor: textColor,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
