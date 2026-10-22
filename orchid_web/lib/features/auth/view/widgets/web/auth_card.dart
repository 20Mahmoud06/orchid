import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';

/// White authentication panel with a restrained border and soft shadow.
class AuthCard extends StatelessWidget {
  final Widget child;

  const AuthCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontal = constraints.maxWidth < 400 ? 24.0 : 36.0;
        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: 40),
          decoration: BoxDecoration(
            color: AppColors.authSection,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.cardBorder.withValues(alpha: 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: child,
        );
      },
    );
  }
}
