import 'package:flutter/material.dart';

import '../../../../core/widgets/app_button.dart';
import '../../data/repositories/inspiration_repository.dart';
import '../../domain/models/inspiration_model.dart';
import 'inspiration_bouquet_tile.dart';
import 'inspiration_busy_indicator.dart';
import 'inspiration_section_card.dart';

class InspirationFeaturedCard extends StatelessWidget {
  const InspirationFeaturedCard({
    super.key,
    required this.items,
    required this.busyId,
    required this.onRemove,
  });

  final List<InspirationItem> items;
  final String? busyId;
  final ValueChanged<InspirationItem> onRemove;

  @override
  Widget build(BuildContext context) {
    return InspirationSectionCard(
      title: 'FEATURED ON THE APP',
      subtitle:
          'Shown to shoppers (newest ${InspirationRepository.maxFeatured})',
      isEmpty: items.isEmpty,
      emptyMessage: 'Nothing featured yet.',
      children: [
        for (final item in items)
          InspirationBouquetTile(
            imagePath: item.imageUrl,
            name: item.displayName,
            ingredients: item.ingredients,
            total: item.total,
            trailing: busyId == item.id
                ? const InspirationBusyIndicator()
                : AppButton(
                    label: 'Remove',
                    variant: AppButtonVariant.text,
                    onPressed: () => onRemove(item),
                  ),
          ),
      ],
    );
  }
}
