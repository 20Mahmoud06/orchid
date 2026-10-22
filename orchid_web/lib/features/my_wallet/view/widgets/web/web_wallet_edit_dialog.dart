import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_fonts.dart';
import '../../../../../shared/widgets/custom_button.dart';
import '../../../../../shared/widgets/custom_text.dart';
import '../wallet_provider.dart';

/// Edit dialog for the wallet owner name / wallet ID / balance, mirroring the
/// mobile [WalletEditDialog] with fixed logical pixels.
class WebWalletEditDialog extends StatelessWidget {
  final String title;
  final String initialValue;
  final String hint;
  final TextInputType? keyboardType;
  final WalletProvider provider;
  final bool isProviderSelected;
  final IconData? icon;

  const WebWalletEditDialog({
    super.key,
    required this.title,
    required this.initialValue,
    required this.hint,
    this.keyboardType,
    required this.provider,
    required this.isProviderSelected,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: initialValue);
    final accent = isProviderSelected
        ? provider.brandColor
        : AppColors.incrementButton;

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
                decoration: BoxDecoration(
                  color: isProviderSelected
                      ? provider.lightColor
                      : AppColors.incrementButton.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon ?? Ionicons.cash_outline,
                  size: 32,
                  color: isProviderSelected
                      ? provider.brandColor
                      : AppColors.textGrey,
                ),
              ),
              const SizedBox(height: 16),
              CustomText(
                text: title,
                fontFamily: AppFonts.goudyOldStyle,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                textColor: AppColors.black,
              ),
              const SizedBox(height: 10),
              CustomText(
                text: hint,
                fontFamily: AppFonts.inriaSerif,
                fontSize: 14,
                textColor: AppColors.textPrimary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 22),
              TextField(
                controller: controller,
                keyboardType: keyboardType ?? TextInputType.text,
                decoration: InputDecoration(
                  hintText: hint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: accent.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: accent.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: accent, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      label: 'CANCEL',
                      fontFamily: AppFonts.goudyOldStyle,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      textColor: AppColors.black,
                      backgroundColor: AppColors.white,
                      height: 48,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [],
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      label: 'SAVE',
                      fontFamily: AppFonts.goudyOldStyle,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      textColor: AppColors.black,
                      backgroundColor: isProviderSelected
                          ? provider.lightColor
                          : AppColors.textFieldPink,
                      height: 48,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [],
                      onPressed: () =>
                          Navigator.of(context).pop(controller.text.trim()),
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
