import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_fonts.dart';
import '../../../../../core/router/app_routes.dart';
import '../../../../../shared/widgets/custom_text.dart';
import '../../../cubit/cart_cubit.dart';
import '../../../cubit/cart_state.dart';
import 'web_cart_widgets.dart';

/// Desktop-first "my cart" page (>= 768px): a scrollable item list with a
/// summary sidebar.
class WebCartView extends StatelessWidget {
  final VoidCallback? onConfirmOrder;
  final VoidCallback onClearCart;
  final VoidCallback onChooseItems;
  final VoidCallback onAddMoreItems;

  const WebCartView({
    super.key,
    required this.onConfirmOrder,
    required this.onClearCart,
    required this.onChooseItems,
    required this.onAddMoreItems,
  });

  @override
  Widget build(BuildContext context) {
    final cart = CartCubit.instance;

    return BlocBuilder<CartCubit, CartState>(
      bloc: cart,
      builder: (context, state) {
        final items = cart.items;
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
                      Row(
                        children: [
                          const Text(
                            'my cart',
                            style: TextStyle(
                              fontFamily: AppFonts.goudyOldStyle,
                              fontSize: 30,
                              fontWeight: FontWeight.w400,
                              color: AppColors.black,
                            ),
                          ),
                          const Spacer(),
                          if (items.isNotEmpty)
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: InkWell(
                                onTap: onClearCart,
                                borderRadius: BorderRadius.circular(10),
                                child: const Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Icon(
                                    Ionicons.trash,
                                    size: 22,
                                    color: AppColors.error,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      CustomText(
                        text: items.isEmpty
                            ? 'your chosen items'
                            : 'you have ${cart.totalItems} '
                                  '${cart.totalItems == 1 ? 'item' : 'items'}',
                        fontFamily: AppFonts.goudyOldStyle,
                        fontSize: 16,
                        textColor: AppColors.primary,
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: items.isEmpty
                            ? WebCartEmptyState(onChooseItems: onChooseItems)
                            : LayoutBuilder(
                                builder: (context, rowConstraints) {
                                  final sideWidth =
                                      (rowConstraints.maxWidth * 0.30).clamp(
                                        280.0,
                                        380.0,
                                      );
                                  return Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: ListView.separated(
                                          padding: const EdgeInsets.only(
                                            bottom: 16,
                                          ),
                                          itemCount: items.length,
                                          separatorBuilder: (_, _) =>
                                              const SizedBox(height: 14),
                                          itemBuilder: (context, index) {
                                            final item = items[index];
                                            return WebCartItemCard(
                                              item: item,
                                              onMessage: () =>
                                                  Navigator.pushNamed(
                                                    context,
                                                    AppRoutes.addMessage,
                                                    arguments: item.id,
                                                  ),
                                              onRemove: () =>
                                                  cart.removeItem(item.id),
                                              onIncrement: () => cart
                                                  .incrementQuantity(item.id),
                                              onDecrement: () => cart
                                                  .decrementQuantity(item.id),
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 28),
                                      SizedBox(
                                        width: sideWidth,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            WebCartButton(
                                              label: 'ADD MORE ITEMS',
                                              height: 48,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              backgroundColor:
                                                  AppColors.background,
                                              textColor: AppColors.primary,
                                              borderColor:
                                                  AppColors.incrementButton,
                                              onPressed: onAddMoreItems,
                                            ),
                                            const SizedBox(height: 12),
                                            WebCheckoutSummary(
                                              total: cart.totalPrice,
                                              onConfirmOrder: onConfirmOrder,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
