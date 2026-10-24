import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_fonts.dart';
import '../../../../../core/router/app_routes.dart';
import '../../../../../shared/widgets/fade_slide_in.dart';
import '../../../../../shared/widgets/slider_direction.dart';
import '../../../../catalog/cubit/catalog_cubit.dart';
import '../../../../catalog/cubit/catalog_state.dart';
import '../../../cubit/inspiration_cubit.dart';
import '../../../cubit/inspiration_state.dart';
import 'web_inspiration_widgets.dart';
import '../../../../../shared/widgets/custom_text.dart';

/// Desktop-first inspiration page (>= 768px). Same colors, copy and behaviour
/// as the mobile screen — heading, subtitle and a responsive card grid.
class InspirationWebView extends StatelessWidget {
  final Animation<double> Function(int index) animationFor;
  final SlideDirection direction;
  final double slideDistance;

  const InspirationWebView({
    super.key,
    required this.animationFor,
    required this.direction,
    required this.slideDistance,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(40, 36, 40, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FadeSlideIn(
                    animation: animationFor(0),
                    direction: direction,
                    distance: slideDistance,
                    child: const CustomText(
                      text: 'inspiration',
                      fontFamily: AppFonts.goudyOldStyle,
                      fontSize: 30,
                      fontWeight: FontWeight.w400,
                      textColor: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FadeSlideIn(
                    animation: animationFor(1),
                    direction: direction,
                    distance: slideDistance,
                    child: const CustomText(
                      text: 'not sure what to choose ?',
                      fontFamily: AppFonts.goudyOldStyle,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      textColor: AppColors.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 4),
                  FadeSlideIn(
                    animation: animationFor(2),
                    direction: direction,
                    distance: slideDistance,
                    child: const CustomText(
                      text: 'take a look at what others are creating',
                      fontFamily: AppFonts.goudyOldStyle,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      textColor: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: BlocBuilder<CatalogCubit, CatalogState>(
                      bloc: CatalogCubit.instance,
                      builder: (context, _) =>
                          BlocBuilder<InspirationCubit, InspirationState>(
                            bloc: InspirationCubit.instance,
                            builder: (context, state) => _buildItems(context),
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItems(BuildContext context) {
    final controller = InspirationCubit.instance;
    final items = controller.items;

    if (controller.isLoading && items.isEmpty) {
      return const WebInspirationMessage(
        message: 'loading inspiration...',
        showLoader: true,
      );
    }
    if (controller.error != null && items.isEmpty) {
      return WebInspirationMessage(
        message:
            'could not load inspiration right now.\ncheck your connection and try again.',
        onRetry: () => controller.load(force: true),
      );
    }
    if (items.isEmpty) {
      return const WebInspirationMessage(
        message: 'no inspiration yet —\nbe the first to create a bouquet!',
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 8),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 620,
        mainAxisExtent: 230,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return WebInspirationCard(
          username: item.username,
          imagePath: item.displayImagePath,
          ingredients: item.ingredients,
          avatarUrl: item.avatarUrl,
          onChoose: () {
            Navigator.pushNamed(
              context,
              AppRoutes.viewBouquet,
              arguments: item,
            );
          },
        );
      },
    );
  }
}
