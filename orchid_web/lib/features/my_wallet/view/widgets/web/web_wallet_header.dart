import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_fonts.dart';
import '../../../../../shared/widgets/custom_text.dart';

/// Centered "my wallet" title (same copy as the mobile app bar).
class WebWalletHeader extends StatelessWidget {
  final VoidCallback? onBackPressed;

  const WebWalletHeader({super.key, this.onBackPressed});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 36,
      child: Center(
        child: CustomText(
          text: 'my wallet',
          fontFamily: AppFonts.goudyOldStyle,
          fontSize: 24,
          textColor: AppColors.black,
        ),
      ),
    );
  }
}
