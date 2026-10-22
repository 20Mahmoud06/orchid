import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_fonts.dart';
import '../../../../../shared/widgets/custom_text.dart';
import '../../../../../shared/widgets/web_radio_indicator.dart';
import '../../../data/message_choice.dart';

/// Yes / No option cards laid out side by side for the wider desktop canvas.
class WebMessageOptionCards extends StatelessWidget {
  final MessageChoice selectedChoice;
  final ValueChanged<MessageChoice> onChoiceSelected;

  const WebMessageOptionCards({
    super.key,
    required this.selectedChoice,
    required this.onChoiceSelected,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _WebMessageOptionCard(
              iconPath: AppAssets.speechBubbleIcon,
              label: 'Yes, add a message.',
              isSelected: selectedChoice == MessageChoice.yes,
              onTap: () => onChoiceSelected(MessageChoice.yes),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _WebMessageOptionCard(
              iconPath: AppAssets.noSpeechBubbleIcon,
              label: 'No, thanks.',
              isSelected: selectedChoice == MessageChoice.no,
              onTap: () => onChoiceSelected(MessageChoice.no),
            ),
          ),
        ],
      ),
    );
  }
}

class _WebMessageOptionCard extends StatelessWidget {
  final String iconPath;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _WebMessageOptionCard({
    required this.iconPath,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

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
              Image.asset(
                iconPath,
                width: 28,
                height: 28,
                fit: BoxFit.contain,
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
