import 'package:flutter/material.dart';

import '../../core/router/app_routes.dart';
import 'web_top_nav_text_link.dart';

/// Centered primary navigation links for the desktop header.
class WebTopNavLinks extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onItemSelected;
  final double spacing;

  const WebTopNavLinks({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
    required this.spacing,
  });

  void _go(BuildContext context, String route) {
    Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        WebTopNavTextLink(
          label: 'Home',
          isSelected: currentIndex == 0,
          onTap: () => onItemSelected(0),
        ),
        SizedBox(width: spacing),
        WebTopNavTextLink(
          label: 'Flowers',
          onTap: () => _go(context, AppRoutes.chooseFlowers),
        ),
        SizedBox(width: spacing),
        WebTopNavTextLink(
          label: 'Bouquets',
          onTap: () => _go(context, AppRoutes.chooseBouquets),
        ),
        SizedBox(width: spacing),
        WebTopNavTextLink(
          label: 'Inspiration',
          onTap: () => _go(context, AppRoutes.inspiration),
        ),
      ],
    );
  }
}
