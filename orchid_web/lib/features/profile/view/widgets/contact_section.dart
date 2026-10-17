import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import 'contact_section_tile.dart';

class ContactSection extends StatelessWidget {
  final List<ContactSectionTile> tiles;

  const ContactSection({
    super.key,
    required this.tiles,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.selectedCategory, width: 1.w),
      ),
      child: Column(
        children: tiles.asMap().entries.map((entry) {
          final index = entry.key;
          final tile = entry.value;
          return Column(
            children: [
              tile,
              if (index < tiles.length - 1)
                Divider(
                  height: 0,
                  thickness: 1.w,
                  color: AppColors.selectedCategory,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}