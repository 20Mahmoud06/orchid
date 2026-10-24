import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/custom_text.dart';
import '../../domain/models/inspiration_model.dart';
import 'inspiration_bouquet_tile.dart';
import 'inspiration_busy_indicator.dart';
import 'inspiration_section_card.dart';

class InspirationCandidatesCard extends StatelessWidget {
  const InspirationCandidatesCard({
    super.key,
    required this.candidates,
    required this.featuredSourceIds,
    required this.busyId,
    required this.onAdd,
  });

  final List<InspirationCandidate> candidates;
  final Set<String> featuredSourceIds;
  final String? busyId;
  final ValueChanged<InspirationCandidate> onAdd;

  @override
  Widget build(BuildContext context) {
    return InspirationSectionCard(
      title: 'RECENT CUSTOM BOUQUETS',
      subtitle: 'From real customer orders',
      isEmpty: candidates.isEmpty,
      emptyMessage: 'No custom bouquets ordered yet.',
      children: [
        for (final candidate in candidates)
          InspirationBouquetTile(
            imagePath: candidate.imageUrl,
            name: candidate.customerName,
            ingredients: candidate.ingredients,
            total: candidate.total,
            trailing: _buildTrailing(candidate),
          ),
      ],
    );
  }

  Widget _buildTrailing(InspirationCandidate candidate) {
    if (busyId == candidate.orderItemId) {
      return const InspirationBusyIndicator();
    }
    if (featuredSourceIds.contains(candidate.orderItemId)) {
      return CustomText(
        text: 'Featured',
        style: AppTextStyles.caption.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      );
    }
    return AppButton(label: 'Add', onPressed: () => onAdd(candidate));
  }
}
