import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_fonts.dart';
import 'custom_text.dart';

/// Top announcement bar: slim blush-pink banner with centered seasonal message.
class WebAnnouncementBar extends StatelessWidget {
  const WebAnnouncementBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 36,
      color: AppColors.storeBlush,
      alignment: Alignment.center,
      child: const CustomText(
        text: '🌸 A little joy, delivered in blooms 🌸',
        fontFamily: AppFonts.inriaSerif,
        fontSize: 13,
        textColor: AppColors.announcementText,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
