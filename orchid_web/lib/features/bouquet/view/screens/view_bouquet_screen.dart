import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../features/bouquet/cubit/bouquet_cubit.dart';
import '../../../../core/app_keys.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text.dart';
import '../../../../shared/widgets/skeleton_image.dart';
import '../../../cart/cubit/cart_cubit.dart';
import '../../../cart/models/cart_item.dart';
import '../../../checkout/cubit/checkout_cubit.dart';
import '../../../inspiration/models/inspiration_item.dart';

class ViewBouquetScreen extends StatelessWidget {
  final VoidCallback? onBackPressed;
  final InspirationItem? bouquet;

  const ViewBouquetScreen({super.key, this.onBackPressed, this.bouquet});

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
              : AppAssets.bouquetTest);

    final description = isFromInspiration
        ? bouquet!.ingredients
        : selectedFlowers
              .map(
                (flower) =>
                    '${bouquetController.getQuantity(flower.id)} ${flower.name.toLowerCase()}',
              )
              .toList();

    final showTwoButtons = !isFromInspiration;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Desktop-first web presentation (>= 768px): a wide, centered bouquet
        // preview with side-by-side actions. Narrow viewports keep the
        // untouched Orchid mobile layout.
        if (constraints.maxWidth >= 768) {
          return _buildWeb(
            context,
            title: title,
            imagePath: imagePath,
            description: description,
            showTwoButtons: showTwoButtons,
            isFromInspiration: isFromInspiration,
          );
        }
        return _buildMobile(
          context,
          title: title,
          imagePath: imagePath,
          description: description,
          showTwoButtons: showTwoButtons,
          isFromInspiration: isFromInspiration,
        );
      },
    );
  }

  /// Desktop-first view bouquet page (>= 768px). Same colors, copy and
  /// behaviour as the mobile screen — heading, a rectangular bouquet photo on
  /// one side with the ingredient list and Edit Bouquet / Looks Good actions
  /// on the other.
  Widget _buildWeb(
    BuildContext context, {
    required String title,
    required String imagePath,
    required List<String> description,
    required bool showTwoButtons,
    required bool isFromInspiration,
  }) {
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
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: AppFonts.goudyOldStyle,
                      fontSize: 30,
                      fontWeight: FontWeight.w400,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Rectangular bouquet photo.
                        Expanded(
                          flex: 5,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: SkeletonImage(
                              path: imagePath,
                              fit: BoxFit.cover,
                              errorWidget: const SkeletonFallbackBox(
                                color: AppColors.fieldPink,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 40),
                        // Details with the actions underneath.
                        Expanded(
                          flex: 6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (description.isNotEmpty)
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: description
                                              .map(
                                                (line) => Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        bottom: 6,
                                                      ),
                                                  child: CustomText(
                                                    text: line,
                                                    fontFamily:
                                                        AppFonts.goudyOldStyle,
                                                    fontSize: 22,
                                                    textColor:
                                                        AppColors.textPrimary,
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              if (showTwoButtons)
                                Row(
                                  children: [
                                    Expanded(
                                      child: CustomButton(
                                        label: 'Edit Bouquet',
                                        fontFamily: AppFonts.goudyOldStyle,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w400,
                                        textColor: AppColors.primary,
                                        backgroundColor: AppColors.background,
                                        height: 54,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: AppColors.incrementButton,
                                          width: 1,
                                        ),
                                        boxShadow: const [],
                                        onPressed: () =>
                                            Navigator.maybePop(context),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _looksGoodButton(
                                        context,
                                        isFromInspiration: isFromInspiration,
                                      ),
                                    ),
                                  ],
                                )
                              else
                                SizedBox(
                                  width: 420,
                                  child: _looksGoodButton(
                                    context,
                                    isFromInspiration: isFromInspiration,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
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

  Widget _looksGoodButton(
    BuildContext context, {
    required bool isFromInspiration,
  }) {
    return CustomButton(
      label: 'Looks Good',
      fontFamily: AppFonts.goudyOldStyle,
      fontSize: 20,
      fontWeight: FontWeight.w400,
      textColor: AppColors.primary,
      backgroundColor: AppColors.incrementButton,
      height: 54,
      borderRadius: BorderRadius.circular(14),
      boxShadow: const [],
      onPressed: () {
        if (isFromInspiration) {
          _saveInspirationToCart(context);
          return;
        }
        _saveArrangementToCart(context);
      },
    );
  }

  /// Mobile layout (unchanged).
  Widget _buildMobile(
    BuildContext context, {
    required String title,
    required String imagePath,
    required List<String> description,
    required bool showTwoButtons,
    required bool isFromInspiration,
  }) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: Column(
            children: [
              CustomAppBar.orchid(title: title, onBackPressed: onBackPressed),
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
                SizedBox(height: 12.h),
                CustomButton(
                  label: 'Edit Bouquet',
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w400,
                  textColor: AppColors.primary,
                  backgroundColor: AppColors.background,
                  height: 60.h,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: AppColors.incrementButton,
                    width: 1.w,
                  ),
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

    // A message typed in the home "what are you celebrating?" flow rides
    // along with the bouquet it was written for: the cart shows it under the
    // line and the message screen pre-fills with it.
    final occasionMessage = _pendingOccasionMessage();

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
          // The cart shows the same picture as the view bouquet screen: a
          // single flower keeps its own photo, a mixed arrangement uses the
          // bouquet preview.
          imagePath: flowers.length == 1
              ? flowers.first.imagePath
              : AppAssets.bouquetTest,
          quantity: 1,
          message: occasionMessage,
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
          message: occasionMessage,
        ),
      );
    }

    CartCubit.instance.addItems(items);
    bouquetController.clear();
    Navigator.pushReplacementNamed(context, AppRoutes.cart);
  }

  /// The message typed in the home celebration section, or null when the
  /// user is not shopping for an occasion.
  String? _pendingOccasionMessage() {
    final checkout = CheckoutCubit.instance;
    if (!checkout.hasMessage) return null;
    final message = checkout.messageText.trim();
    return message.isEmpty ? null : message;
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
        message: _pendingOccasionMessage(),
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

  void _showMessage(String message) {
    final messenger = scaffoldMessengerKey.currentState;
    if (messenger == null) return;
    showAppSnackBarWith(messenger, message);
  }
}
