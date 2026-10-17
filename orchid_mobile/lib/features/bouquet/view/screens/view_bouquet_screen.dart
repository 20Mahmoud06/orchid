import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../features/bouquet/cubit/bouquet_cubit.dart';
import '../../../../core/app_keys.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text.dart';
import '../../../../shared/widgets/skeleton_image.dart';
import '../../../cart/cubit/cart_cubit.dart';
import '../../../cart/models/cart_item.dart';
import '../../../inspiration/models/inspiration_item.dart';

class ViewBouquetScreen extends StatelessWidget {
  final VoidCallback? onBackPressed;
  final InspirationItem? bouquet;

  const ViewBouquetScreen({
    super.key,
    this.onBackPressed,
    this.bouquet,
  });

  @override
  Widget build(BuildContext context) {
    final bouquetController = BouquetCubit.instance;
    final selectedFlowers = bouquetController.selectedFlowers;
    final isFromInspiration = bouquet != null;

    final title = isFromInspiration
        ? 'your bouquet'
        : (selectedFlowers.length == 1 ? 'View Your Flower' : 'your bouquet');

    final imagePath = isFromInspiration
        ? (bouquet!.imagePath)
        : (selectedFlowers.length == 1
            ? selectedFlowers.first.imagePath
            : 'assets/images/bouquet_test.png');

    final description = isFromInspiration
        ? bouquet!.ingredients
        : selectedFlowers
            .map((flower) => '${bouquetController.getQuantity(flower.id)} ${flower.name.toLowerCase()}')
            .toList();

    final showTwoButtons = !isFromInspiration;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: Column(
            children: [
              CustomAppBar.orchid(
                title: title,
                onBackPressed: onBackPressed,
              ),
              SizedBox(height: 24.h),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SkeletonImage(
                        path: imagePath,
                        width: 280.w,
                        fit: BoxFit.contain,
                        placeholderSize: Size(280.w, 280.h),
                        errorWidget: const SkeletonFallbackBox(
                          color: AppColors.fieldPink,
                        ),
                      ),
                      SizedBox(height: 32.h),
                      if (description.isNotEmpty)
                        Column(
                          children: description
                              .map(
                                (line) => CustomText(
                                  text: line,
                                  fontFamily: AppFonts.goudyOldStyle,
                                  fontSize: 24.sp,
                                  textColor: AppColors.textPrimary,
                                  textAlign: TextAlign.center,
                                ),
                              )
                              .toList(),
                        ),
                    ],
                  ),
                ),
              ),
              if (showTwoButtons) ...[
                SizedBox(height: 12.h,),
                CustomButton(
                  label: 'Edit Bouquet',
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w400,
                  textColor: AppColors.primary,
                  backgroundColor: AppColors.background,
                  height: 60.h,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColors.incrementButton, width: 1.w),
                  boxShadow: const [],
                  onPressed: () => Navigator.maybePop(context),
                ),
                SizedBox(height: 12.h),
              ],
              CustomButton(
                label: 'Looks Good',
                fontFamily: AppFonts.goudyOldStyle,
                fontSize: 24.sp,
                fontWeight: FontWeight.w400,
                textColor: AppColors.primary,
                backgroundColor: AppColors.incrementButton,
                height: 60.h,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: const [],
                onPressed: () {
                  if (isFromInspiration) {
                    _saveInspirationToCart(context);
                    return;
                  }
                  _saveArrangementToCart(context);
                },
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  /// Saves the current arrangement as cart line items: one custom bouquet
  /// holding the flower composition, plus one line per ready bouquet. The
  /// builder is cleared so the next arrangement becomes a new line, and the
  /// cart (persisted on device) keeps the draft if the app is closed.
  void _saveArrangementToCart(BuildContext context) {
    final bouquetController = BouquetCubit.instance;
    final flowers = bouquetController.selectedFlowers;
    final readyBouquets = bouquetController.selectedReadyBouquets;

    if (flowers.isEmpty && readyBouquets.isEmpty) {
      _showMessage('your bouquet is empty');
      return;
    }

    final items = <CartItem>[];

    if (flowers.isNotEmpty) {
      final flowerTotal = flowers.fold<int>(
        0,
        (sum, flower) =>
            sum + flower.price * bouquetController.getQuantity(flower.id),
      );
      items.add(
        CartItem(
          id: 'custom-${DateTime.now().microsecondsSinceEpoch}',
          name: 'Custom Bouquet',
          price: flowerTotal,
          imagePath: flowers.first.imagePath,
          quantity: 1,
          components: [
            for (final flower in flowers)
              CartItemComponent(
                name: flower.name,
                quantity: bouquetController.getQuantity(flower.id),
                unitPrice: flower.price,
                productId: flower.id,
              ),
          ],
        ),
      );
    }

    for (final bouquet in readyBouquets) {
      items.add(
        CartItem(
          id: bouquet.id,
          name: bouquet.name,
          price: bouquet.price,
          imagePath: bouquet.imagePath,
          quantity: bouquetController.getQuantity(bouquet.id),
        ),
      );
    }

    CartCubit.instance.addItems(items);
    bouquetController.clear();
    Navigator.pushReplacementNamed(context, AppRoutes.cart);
  }

  /// Rebuilds a featured inspiration bouquet as a cart line, then opens the
  /// cart. Falls back to the plain message flow for legacy items that carry no
  /// flower composition.
  void _saveInspirationToCart(BuildContext context) {
    final inspiration = bouquet;
    if (inspiration == null || inspiration.flowers.isEmpty) {
      Navigator.pushNamed(context, AppRoutes.addMessage);
      return;
    }

    final total = inspiration.flowers.fold<int>(
      0,
      (sum, flower) => sum + flower.unitPrice * flower.quantity,
    );

    CartCubit.instance.addItems([
      CartItem(
        id: 'custom-${DateTime.now().microsecondsSinceEpoch}',
        name: 'Custom Bouquet',
        price: total,
        imagePath: inspiration.imagePath,
        quantity: 1,
        components: [
          for (final flower in inspiration.flowers)
            CartItemComponent(
              name: flower.name,
              quantity: flower.quantity,
              unitPrice: flower.unitPrice,
              productId: flower.productId,
            ),
        ],
      ),
    ]);
    Navigator.pushReplacementNamed(context, AppRoutes.cart);
  }

  void _showMessage(String message) {    final messenger = scaffoldMessengerKey.currentState;
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.darkGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          content: CustomText(
            text: message,
            fontFamily: AppFonts.inriaSerif,
            fontSize: 14.sp,
            textColor: AppColors.white,
          ),
        ),
      );
  }
}

