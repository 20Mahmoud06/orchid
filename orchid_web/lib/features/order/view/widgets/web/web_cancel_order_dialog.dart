import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_fonts.dart';
import '../../../../../shared/widgets/custom_button.dart';
import '../../../../../shared/widgets/custom_text.dart';

/// Cancel confirmation (single order or all orders), the mobile dialog at
/// desktop sizing. Pops `true` when the shopper confirms.
class WebCancelOrderDialog extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String confirmLabel;

  const WebCancelOrderDialog({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.confirmLabel,
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
                child: Icon(icon, size: 32, color: AppColors.redText),
              ),
              const SizedBox(height: 16),
              CustomText(
                text: title,
                fontFamily: AppFonts.goudyOldStyle,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                textColor: AppColors.black,
              ),
              const SizedBox(height: 12),
              CustomText(
                text: message,
                fontFamily: AppFonts.goudyOldStyle,
                fontSize: 14,
                textColor: AppColors.textPrimary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      label: 'KEEP',
                      fontFamily: AppFonts.goudyOldStyle,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      textColor: AppColors.black,
                      backgroundColor: AppColors.white,
                      height: 48,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [],
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      label: confirmLabel,
                      fontFamily: AppFonts.goudyOldStyle,
                      fontSize: confirmLabel.length > 14 ? 13 : 16,
                      fontWeight: FontWeight.bold,
                      textColor: AppColors.white,
                      backgroundColor: AppColors.canceledText,
                      height: 48,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [],
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
