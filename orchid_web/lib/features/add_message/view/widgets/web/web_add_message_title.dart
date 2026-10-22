import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_fonts.dart';
import '../../../../../shared/widgets/custom_text.dart';

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
