import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/custom_text.dart';

class InspirationSectionCard extends StatelessWidget {
  const InspirationSectionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isEmpty,
    required this.emptyMessage,
    required this.children,
  });

  final String title;
  final String subtitle;
  final bool isEmpty;
  final String emptyMessage;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: title,
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                CustomText(text: subtitle, style: AppTextStyles.caption),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          if (isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: CustomText(
                  text: emptyMessage,
                  style: AppTextStyles.bodySecondary,
                ),
              ),
            )
          else
            for (int i = 0; i < children.length; i++) ...[
              children[i],
              if (i < children.length - 1)
                const Divider(height: 1, color: AppColors.border),
            ],
        ],
      ),
    );
  }
}
