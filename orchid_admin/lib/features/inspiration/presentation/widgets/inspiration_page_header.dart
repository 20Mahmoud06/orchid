import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/custom_text.dart';

class InspirationPageHeader extends StatelessWidget {
  const InspirationPageHeader({
    super.key,
    required this.isMobile,
    required this.onAdd,
    required this.onRefresh,
  });

  final bool isMobile;
  final VoidCallback onAdd;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final title = CustomText(
      text: 'Inspiration',
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      ),
    );
    final subtitle = CustomText(
      text: 'Create featured bouquets for the web and mobile Inspiration tabs.',
      style: AppTextStyles.bodySecondary,
    );
    final buttons = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppButton(label: 'Add Inspiration', icon: Icons.add, onPressed: onAdd),
        const SizedBox(width: 12),
        AppButton(
          label: 'Refresh',
          icon: Icons.refresh_rounded,
          variant: AppButtonVariant.outline,
          onPressed: onRefresh,
        ),
      ],
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title,
          const SizedBox(height: 6),
          subtitle,
          const SizedBox(height: 16),
          buttons,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [title, const SizedBox(height: 6), subtitle],
          ),
        ),
        buttons,
      ],
    );
  }
}
