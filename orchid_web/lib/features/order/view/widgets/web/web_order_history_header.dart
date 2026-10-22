import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_fonts.dart';
import '../../../../../shared/widgets/custom_text.dart';

/// Centered "orders history" title with the cancel-all action on the right.
class WebOrderHistoryHeader extends StatelessWidget {
  final VoidCallback? onCancelAll;
  final bool showCancelAll;

  const WebOrderHistoryHeader({
    super.key,
    this.onCancelAll,
    this.showCancelAll = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: Stack(
        children: [
          const Center(
            child: CustomText(
              text: 'orders history',
              fontFamily: AppFonts.goudyOldStyle,
              fontSize: 24,
              textColor: AppColors.black,
            ),
          ),
          if (showCancelAll)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: InkWell(
                  onTap: onCancelAll,
                  borderRadius: BorderRadius.circular(10),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(
                      Ionicons.trash,
                      size: 22,
                      color: AppColors.redText,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
