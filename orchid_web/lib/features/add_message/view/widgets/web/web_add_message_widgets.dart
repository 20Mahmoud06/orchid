import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_fonts.dart';
import '../../../../../shared/widgets/custom_text.dart';
import '../../../data/message_choice.dart';

/// Desktop-first building blocks for the Add Message page.
///
/// Presentation only: the colors, copy and behaviour mirror the mobile screen
/// exactly, sized in fixed logical pixels. On the web the app pins the design
/// size, so these values render 1:1 on any monitor — the same convention as the
/// other web pages.

/// Centered "Add a message" title.
class WebAddMessageHeader extends StatelessWidget {
  final VoidCallback? onBackPressed;

  const WebAddMessageHeader({super.key, this.onBackPressed});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 36,
      child: Center(
        child: CustomText(
          text: 'Add a message',
          fontFamily: AppFonts.goudyOldStyle,
          fontSize: 24,
          textColor: AppColors.black,
        ),
      ),
    );
  }
}

/// Centered "would you like to add a message ?" prompt.
class WebAddMessageTitle extends StatelessWidget {
  const WebAddMessageTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CustomText(
        text: 'would you like to\nadd a message ?',
        fontFamily: AppFonts.goudyOldStyle,
        fontSize: 22,
        textColor: AppColors.primary,
        textAlign: TextAlign.center,
        height: 1.3,
      ),
    );
  }
}

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
                      color:
                          AppColors.selectedCategory.withValues(alpha: 0.08),
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
                color:
                    isSelected ? AppColors.black : AppColors.iconColor,
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
              _WebRadioIndicator(isSelected: isSelected),
            ],
          ),
        ),
      ),
    );
  }
}

class _WebRadioIndicator extends StatelessWidget {
  final bool isSelected;

  const _WebRadioIndicator({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppColors.black : AppColors.incrementButton,
          width: isSelected ? 2 : 1.5,
        ),
      ),
      child: isSelected
          ? Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.black,
                ),
              ),
            )
          : null,
    );
  }
}

/// Fixed-height message text box with the "count \ max" counter.
class WebMessageInputField extends StatelessWidget {
  static const int maxCharacters = 300;

  final TextEditingController controller;
  final int characterCount;
  final ValueChanged<String>? onChanged;

  const WebMessageInputField({
    super.key,
    required this.controller,
    required this.characterCount,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.cardBorder.withValues(alpha: 0.8),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          TextField(
            controller: controller,
            onChanged: onChanged,
            maxLines: 6,
            minLines: 6,
            maxLength: maxCharacters,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            inputFormatters: [
              LengthLimitingTextInputFormatter(maxCharacters),
            ],
            style: const TextStyle(
              fontFamily: AppFonts.goudyOldStyle,
              fontSize: 15,
              color: AppColors.black,
              height: 1.5,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.fromLTRB(16, 14, 16, 40),
              counterText: '',
            ),
          ),
          Positioned(
            right: 12,
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.background.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomText(
                text: '$characterCount \\ $maxCharacters',
                fontFamily: AppFonts.goudyOldStyle,
                fontSize: 12,
                textColor: AppColors.iconColor.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shown when "No" is selected — "No message added".
class WebMessageEmptyPlaceholder extends StatelessWidget {
  const WebMessageEmptyPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.background.withValues(alpha: 0.6),
                  AppColors.background.withValues(alpha: 0.2),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset(
                AppAssets.noSpeechBubbleIcon,
                width: 56,
                height: 56,
                fit: BoxFit.contain,
                color: AppColors.iconColor.withValues(alpha: 0.35),
              ),
            ),
          ),
          const SizedBox(height: 20),
          CustomText(
            text: 'No message added',
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 18,
            textColor: AppColors.primary.withValues(alpha: 0.6),
            fontWeight: FontWeight.w500,
          ),
          const SizedBox(height: 6),
          CustomText(
            text: 'You can add it later at any time',
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 14,
            textColor: AppColors.iconColor.withValues(alpha: 0.4),
            fontWeight: FontWeight.w300,
          ),
        ],
      ),
    );
  }
}

/// Inline validation banner ("Please enter a message to continue").
class WebValidationErrorMessage extends StatelessWidget {
  final String message;

  const WebValidationErrorMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.validationBorder.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.validationBorder.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.validationBorder.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.error_outline_rounded,
                size: 16,
                color: AppColors.validationBorder,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: CustomText(
              text: message,
              fontFamily: AppFonts.goudyOldStyle,
              fontSize: 14,
              textColor: AppColors.error,
              fontWeight: FontWeight.w400,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
