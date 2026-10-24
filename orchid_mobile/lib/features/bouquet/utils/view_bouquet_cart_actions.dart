import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/app_keys.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/router/app_routes.dart';
import '../../../shared/widgets/custom_text.dart';
import '../../bouquet/cubit/bouquet_cubit.dart';
import '../../bouquet/utils/bouquet_naming.dart';
import '../../cart/cubit/cart_cubit.dart';
import '../../cart/models/cart_item.dart';
import '../../checkout/cubit/checkout_cubit.dart';
import '../../inspiration/models/inspiration_item.dart';

/// Saves the current arrangement as cart line items: one custom bouquet
/// holding the flower composition, plus one line per ready bouquet. The
/// builder is cleared so the next arrangement becomes a new line, and the
/// cart (persisted on device) keeps the draft if the app is closed.
void saveArrangementToCart(BuildContext context) {
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
    final totalFlowerCount = flowers.fold<int>(
      0,
      (sum, flower) => sum + bouquetController.getQuantity(flower.id),
    );
    final singleFlower = BouquetNaming.singleFlower(
      flowers.map(
        (flower) => BouquetFlowerLine(
          name: flower.name,
          productId: flower.id,
          imagePath: flower.imagePath,
        ),
      ),
    );
    items.add(
      CartItem(
        id: 'custom-${DateTime.now().microsecondsSinceEpoch}',
        name: singleFlower == null
            ? 'Custom Bouquet'
            : BouquetNaming.flowerTitle(
                singleFlower.name,
                quantity: totalFlowerCount,
              ),
        price: flowerTotal,
        // The cart shows the same picture as the view bouquet screen: a
        // single flower keeps its own photo, a mixed arrangement uses the
        // bouquet preview.
        imagePath: singleFlower == null
            ? AppAssets.bouquetTest
            : BouquetNaming.singleFlowerImage(
                productId: singleFlower.productId,
                name: singleFlower.name,
                storedImage: singleFlower.imagePath,
                fallback: AppAssets.bouquetTest,
              ),
        quantity: 1,
        message: occasionMessage,
        components: [
          for (final flower in flowers)
            CartItemComponent(
              name: flower.name,
              quantity: bouquetController.getQuantity(flower.id),
              unitPrice: flower.price,
              productId: flower.id,
              imagePath: flower.imagePath,
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

/// Rebuilds a featured inspiration bouquet as a cart line, then opens the
/// cart. Falls back to the plain message flow for legacy items that carry no
/// flower composition.
void saveInspirationToCart(BuildContext context, InspirationItem? inspiration) {
  if (inspiration == null || inspiration.flowers.isEmpty) {
    Navigator.pushNamed(context, AppRoutes.addMessage);
    return;
  }

  final total = inspiration.flowers.fold<int>(
    0,
    (sum, flower) => sum + flower.unitPrice * flower.quantity,
  );
  final totalFlowerCount = inspiration.flowers.fold<int>(
    0,
    (sum, flower) => sum + flower.quantity,
  );
  final singleFlower = BouquetNaming.singleFlower(
    inspiration.flowers.map(
      (flower) =>
          BouquetFlowerLine(name: flower.name, productId: flower.productId),
    ),
  );
  final usesUploadedPhoto = inspiration.sourceOrderItemId == null;

  CartCubit.instance.addItems([
    CartItem(
      id: 'custom-${DateTime.now().microsecondsSinceEpoch}',
      name: singleFlower == null
          ? 'Custom Bouquet'
          : BouquetNaming.flowerTitle(
              singleFlower.name,
              quantity: totalFlowerCount,
            ),
      price: total,
      imagePath: usesUploadedPhoto || singleFlower == null
          ? inspiration.imagePath
          : BouquetNaming.singleFlowerImage(
              productId: singleFlower.productId,
              name: singleFlower.name,
              fallback: inspiration.imagePath,
            ),
      quantity: 1,
      message: _pendingOccasionMessage(),
      components: [
        for (final flower in inspiration.flowers)
          CartItemComponent(
            name: flower.name,
            quantity: flower.quantity,
            unitPrice: flower.unitPrice,
            productId: flower.productId,
            imagePath: usesUploadedPhoto
                ? inspiration.imagePath
                : BouquetNaming.catalogFlowerImage(
                    flower.productId,
                    flower.name,
                  ),
          ),
      ],
    ),
  ]);
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

void _showMessage(String message) {
  final messenger = scaffoldMessengerKey.currentState;
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
