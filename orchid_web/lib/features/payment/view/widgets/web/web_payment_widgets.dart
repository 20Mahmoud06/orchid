import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_fonts.dart';
import '../../../../../shared/widgets/custom_text.dart';
import '../../../../../shared/widgets/web_radio_indicator.dart';

/// Desktop-first building blocks for the Payment page.
///
/// Presentation only: the colors, copy and behaviour mirror the mobile screen
/// exactly, sized in fixed logical pixels (the web app pins the design size, so
/// these render 1:1 on any monitor — the same convention as the other web
/// pages).

/// Centered "Order Summary" title (same copy as the mobile payment header).
class WebPaymentHeader extends StatelessWidget {
  final VoidCallback? onBackPressed;

  const WebPaymentHeader({super.key, this.onBackPressed});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 36,
      child: Center(
        child: CustomText(
          text: 'Order Summary',
          fontFamily: AppFonts.goudyOldStyle,
          fontSize: 24,
          textColor: AppColors.black,
        ),
      ),
    );
  }
}

/// Bordered card holding the payment illustration.
class WebPaymentIllustrationCard extends StatelessWidget {
  const WebPaymentIllustrationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.incrementButton, width: 1),
      ),
      child: SizedBox(
        height: 260,
        child: Image.asset(AppAssets.payment, fit: BoxFit.contain),
      ),
    );
  }
}

/// Radio-style payment method card (cash / credit-debit card / wallet).
class WebPaymentMethodCard extends StatelessWidget {
  final String? iconPath;
  final IconData? icon;
  final Widget? customIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const WebPaymentMethodCard({
    super.key,
    this.iconPath,
    this.icon,
    this.customIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  }) : assert(
         iconPath != null || icon != null || customIcon != null,
         'Either iconPath, icon, or customIcon must be provided',
       );

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.selectedCategory
                  : AppColors.incrementButton,
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.selectedCategory.withValues(alpha: 0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              if (customIcon != null)
                customIcon!
              else if (iconPath != null)
                Image.asset(
                  iconPath!,
                  width: 28,
                  height: 28,
                  fit: BoxFit.contain,
                  color: isSelected ? AppColors.black : AppColors.iconColor,
                )
              else
                Icon(
                  icon,
                  size: 24,
                  color: isSelected ? AppColors.black : AppColors.iconColor,
                ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomText(
                  text: label,
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 16,
                  textColor: isSelected
                      ? AppColors.black
                      : AppColors.black.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(width: 12),
              WebRadioIndicator(isSelected: isSelected),
            ],
          ),
        ),
      ),
    );
  }
}

/// Modal shown when the shopper confirms a cash payment. Mirrors the desktop
/// `BouquetOptionsDialog` sizing (fixed logical pixels, maxWidth 440) so it has
/// the same size as the bouquet/flower chooser used on the cart and home
/// screens on desktop web.
class WebCashConfirmationDialog extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const WebCashConfirmationDialog({
    super.key,
    required this.onCancel,
    required this.onConfirm,
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
                  color: AppColors.textFieldPink,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Ionicons.cash_outline,
                  size: 32,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Confirm Cash Payment',
                style: TextStyle(
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'You will pay in cash upon delivery. Do you want to confirm this order?',
                style: TextStyle(
                  fontFamily: AppFonts.inriaSerif,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textFieldPink,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'CONFIRM',
                    style: TextStyle(
                      fontFamily: AppFonts.goudyOldStyle,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.storeOutlineBorder),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'CANCEL',
                    style: TextStyle(
                      fontFamily: AppFonts.goudyOldStyle,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
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
