import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_fonts.dart';
import '../../../../../shared/widgets/custom_text.dart';

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
            inputFormatters: [LengthLimitingTextInputFormatter(maxCharacters)],
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
