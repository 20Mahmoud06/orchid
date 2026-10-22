import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_fonts.dart';
import '../../../../../shared/widgets/custom_text.dart';

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
