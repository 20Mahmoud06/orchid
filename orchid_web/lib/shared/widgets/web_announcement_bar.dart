import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_fonts.dart';

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
      child: const Text(
        '🌸 A little joy, delivered in blooms 🌸',
        style: TextStyle(
          fontFamily: AppFonts.inriaSerif,
          fontSize: 13,
          color: AppColors.announcementText,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
