import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import 'package:ORCHID/core/constants/app_colors.dart';
import 'package:ORCHID/core/constants/app_fonts.dart';
import 'package:ORCHID/shared/widgets/custom_text.dart';

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
