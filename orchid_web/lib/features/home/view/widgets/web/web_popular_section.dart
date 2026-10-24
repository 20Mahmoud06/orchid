import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_fonts.dart';
import 'web_popular_product_card.dart';
import '../../../../../shared/widgets/custom_text.dart';

typedef WebPopularItem = ({String id, String name, String price, String image});

/// Shared desktop section: title, "View all" link and a responsive product
/// grid. Used by both the popular bouquets and popular flowers sections.
class WebPopularSection extends StatelessWidget {
  final String title;
  final String viewAllRoute;
  final List<WebPopularItem> items;
  final bool Function(String id) isFavorite;
  final ValueChanged<String> onToggleFavorite;

  const WebPopularSection({
    super.key,
    required this.title,
    required this.viewAllRoute,
    required this.items,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: CustomText(
                text: title,
                fontFamily: AppFonts.goudyOldStyle,
                fontSize: 26,
                fontWeight: FontWeight.w600,
                textColor: AppColors.storeDeepGreen,
              ),
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, viewAllRoute),
                behavior: HitTestBehavior.opaque,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomText(
                      text: 'View all',
                      fontFamily: AppFonts.inriaSerif,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      textColor: AppColors.storeDeepGreen,
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward,
                      size: 15,
                      color: AppColors.storeDeepGreen,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerLeft,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 290,
              mainAxisExtent: 270,
              crossAxisSpacing: 18,
              mainAxisSpacing: 18,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return WebPopularProductCard(
                imageUrl: item.image,
                title: item.name,
                price: item.price,
                isFavorite: isFavorite(item.id),
                onToggle: () => onToggleFavorite(item.id),
                onTap: () => Navigator.pushNamed(context, viewAllRoute),
              );
            },
          ),
        ),
      ],
    );
  }
}
