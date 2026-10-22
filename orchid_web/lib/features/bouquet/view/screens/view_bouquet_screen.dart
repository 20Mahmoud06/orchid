import 'package:flutter/material.dart';

import '../../../../core/app_keys.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../features/bouquet/cubit/bouquet_cubit.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../../../cart/cubit/cart_cubit.dart';
import '../../../cart/models/cart_item.dart';
import '../../../checkout/cubit/checkout_cubit.dart';
import '../../../inspiration/models/inspiration_item.dart';
import '../widgets/view_bouquet_mobile_view.dart';
import '../widgets/web/view_bouquet_web_view.dart';

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
          return ViewBouquetWebView(
            title: title,
            imagePath: imagePath,
            description: description,
            showTwoButtons: showTwoButtons,
            onEditBouquet: () => Navigator.maybePop(context),
            onLooksGood: () =>
                _handleLooksGood(context, isFromInspiration: isFromInspiration),
          );
        }
        return ViewBouquetMobileView(
          title: title,
          imagePath: imagePath,
          description: description,
          showTwoButtons: showTwoButtons,
          onBackPressed: onBackPressed,
          onEditBouquet: () => Navigator.maybePop(context),
          onLooksGood: () =>
              _handleLooksGood(context, isFromInspiration: isFromInspiration),
        );
      },
    );
  }

  void _handleLooksGood(
    BuildContext context, {
    required bool isFromInspiration,
  }) {
    if (isFromInspiration) {
      _saveInspirationToCart(context);
      return;
    }
    _saveArrangementToCart(context);
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
