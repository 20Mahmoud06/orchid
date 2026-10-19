import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_text.dart';
import '../../../../shared/widgets/fade_slide_in.dart';
import '../../../../shared/widgets/slider_direction.dart';
import '../../cubit/inspiration_cubit.dart';
import '../../cubit/inspiration_state.dart';
import '../widgets/inspiration_card.dart';
import '../widgets/web/web_inspiration_widgets.dart';

class InspirationScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;

  const InspirationScreen({
    super.key,
    this.onBackPressed,
  });

  @override
  State<InspirationScreen> createState() => _InspirationScreenState();
}

class _InspirationScreenState extends State<InspirationScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const int _itemCount = 4;
  static const double _slideDistance = 14;
  static const SlideDirection _direction = SlideDirection.leftToRight;

  @override
  void initState() {
    super.initState();
    InspirationCubit.instance.load();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Animation<double> _animFor(int index) {
    final start = (index / _itemCount) * 0.55;
    final end = (start + 0.45).clamp(0.0, 1.0);
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Desktop-first web presentation (>= 768px): a wide heading and a
        // responsive grid of inspiration cards. Narrow viewports keep the
        // untouched Orchid mobile layout.
        if (constraints.maxWidth >= 768) {
          return _buildWeb(context);
        }
        return _buildMobile();
      },
    );
  }

  /// Desktop-first inspiration page (>= 768px). Same colors, copy and behaviour
  /// as the mobile screen — heading, subtitle and a responsive card grid.
  Widget _buildWeb(BuildContext context) {
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
                    animation: _animFor(0),
                    direction: _direction,
                    distance: _slideDistance,
                    child: const Text(
                      'inspiration',
                      style: TextStyle(
                        fontFamily: AppFonts.goudyOldStyle,
                        fontSize: 30,
                        fontWeight: FontWeight.w400,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FadeSlideIn(
                    animation: _animFor(1),
                    direction: _direction,
                    distance: _slideDistance,
                    child: const Text(
                      'not sure what to choose ?',
                      style: TextStyle(
                        fontFamily: AppFonts.goudyOldStyle,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkGreen,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  FadeSlideIn(
                    animation: _animFor(2),
                    direction: _direction,
                    distance: _slideDistance,
                    child: const Text(
                      'take a look at what others are creating',
                      style: TextStyle(
                        fontFamily: AppFonts.goudyOldStyle,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: BlocBuilder<InspirationCubit, InspirationState>(
                      bloc: InspirationCubit.instance,
                      builder: (context, state) => _buildWebItems(context),
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

  Widget _buildWebItems(BuildContext context) {
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
          imagePath: item.imagePath,
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

  /// Mobile layout (unchanged).
  Widget _buildMobile() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            FadeSlideIn(
              animation: _animFor(0),
              direction: _direction,
              distance: _slideDistance,
              child: CustomAppBar.orchid(
                title: 'inspiration',
                onBackPressed: widget.onBackPressed,
              ),
            ),
            SizedBox(height: 4.h),
            FadeSlideIn(
              animation: _animFor(1),
              direction: _direction,
              distance: _slideDistance,
              child: CustomText(
                text: 'not sure what to choose ?',
                fontFamily: AppFonts.goudyOldStyle,
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                textColor: AppColors.darkGreen,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 2.h),
            FadeSlideIn(
              animation: _animFor(2),
              direction: _direction,
              distance: _slideDistance,
              child: CustomText(
                text: 'take a look at what others are creating',
                fontFamily: AppFonts.goudyOldStyle,
                fontSize: 15.sp,
                fontWeight: FontWeight.w400,
                textColor: AppColors.black,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: FadeSlideIn(
                animation: _animFor(3),
                direction: _direction,
                distance: _slideDistance,
                child: BlocBuilder<InspirationCubit, InspirationState>(
                  bloc: InspirationCubit.instance,
                  builder: (context, state) {
                    final controller = InspirationCubit.instance;
                    final items = controller.items;

                    if (controller.isLoading && items.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (controller.error != null && items.isEmpty) {
                      return _CenteredMessage(
                        message:
                            'could not load inspiration right now.\ncheck your connection and try again.',
                        onRetry: () =>
                            controller.load(force: true),
                      );
                    }
                    if (items.isEmpty) {
                      return const _CenteredMessage(
                        message:
                            'no inspiration yet —\nbe the first to create a bouquet!',
                      );
                    }

                    return ListView.separated(
                      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
                      itemCount: items.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 16.h),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return InspirationCard(
                          username: item.username,
                          imagePath: item.imagePath,
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
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomText(
              text: message,
              fontFamily: AppFonts.goudyOldStyle,
              fontSize: 16.sp,
              textColor: AppColors.textSecondary,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: 12.h),
              TextButton(
                onPressed: onRetry,
                child: CustomText(
                  text: 'try again',
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  textColor: AppColors.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
