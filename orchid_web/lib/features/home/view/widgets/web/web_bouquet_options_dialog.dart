import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import 'package:ORCHID/core/constants/app_colors.dart';
import 'package:ORCHID/core/constants/app_fonts.dart';

/// "Your Message Is Ready" dialog offering the two bouquet options.
class WebBouquetOptionsDialog extends StatelessWidget {
  final VoidCallback onBuyExisting;
  final VoidCallback onCreateBouquet;

  const WebBouquetOptionsDialog({
    super.key,
    required this.onBuyExisting,
    required this.onCreateBouquet,
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
                  Ionicons.gift_outline,
                  size: 32,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Your Message Is Ready',
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
                'Choose a bouquet for your celebration. Buy an existing bouquet or create your own.',
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
                  onPressed: onBuyExisting,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textFieldPink,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'BUY EXISTING BOUQUET',
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
                  onPressed: onCreateBouquet,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.storeOutlineBorder),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'CREATE MY BOUQUET',
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
