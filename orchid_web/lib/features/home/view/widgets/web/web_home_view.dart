import 'package:flutter/material.dart';

import 'web_home_widgets.dart';
import 'web_popular_bouquets_section.dart';
import 'web_popular_flowers_section.dart';

/// Desktop storefront (>= 768px): hero, occasions, popular products, custom
/// bouquet banner and footer.
class WebHomeView extends StatelessWidget {
  const WebHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            WebStoreSection(verticalPadding: 24, child: WebHeroSection()),
            WebStoreSection(verticalPadding: 20, child: WebOccasionsSection()),
            WebStoreSection(
              verticalPadding: 20,
              child: WebPopularBouquetsSection(),
            ),
            WebStoreSection(
              verticalPadding: 20,
              child: WebPopularFlowersSection(),
            ),
            WebStoreSection(
              verticalPadding: 24,
              child: WebCustomBouquetBanner(),
            ),
            WebHomeFooter(),
          ],
        ),
      ),
    );
  }
}
