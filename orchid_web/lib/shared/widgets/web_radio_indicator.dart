import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Desktop radio indicator used by the web selectable option cards.
class WebRadioIndicator extends StatelessWidget {
  final bool isSelected;

  const WebRadioIndicator({super.key, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppColors.black : AppColors.incrementButton,
          width: isSelected ? 2 : 1.5,
        ),
      ),
      child: isSelected
          ? Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.black,
                ),
              ),
            )
          : null,
    );
  }
}
