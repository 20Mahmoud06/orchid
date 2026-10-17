import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ionicons/ionicons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/viewport.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart' show CustomButton;
import '../../../../shared/widgets/custom_text.dart';
import '../../../../shared/widgets/bouquet_options_dialog.dart';
import '../../cubit/cart_cubit.dart';
import '../../cubit/cart_state.dart';
import '../../models/cart_item.dart';
import '../widgets/cart_item_card.dart';
import '../widgets/checkout_summary.dart';
import '../widgets/web/web_cart_widgets.dart';

/// Cart screen listing the user's added items with a checkout summary.
class CartScreen extends StatelessWidget {
  final VoidCallback? onBackPressed;
  final VoidCallback? onConfirmOrder;

  const CartScreen({super.key, this.onBackPressed, this.onConfirmOrder});

  @override
  Widget build(BuildContext context) {
    final cart = CartCubit.instance;

    return LayoutBuilder(
      builder: (context, constraints) {
        return BlocBuilder<CartCubit, CartState>(
          bloc: cart,
          builder: (context, state) {
            final items = cart.items;
            // Desktop-first web presentation (>= 768px): a wide two-column
            // layout. Narrow viewports keep the untouched Orchid mobile layout.
            if (constraints.maxWidth >= 768) {
              return _buildWeb(context, cart, items);
            }
            return _buildMobile(context, cart);
          },
        );
      },
    );
  }

  /// Desktop-first "my cart" page (>= 768px). Same colors, copy and behaviour
  /// as the mobile screen — a scrollable item list with a summary sidebar.
  Widget _buildWeb(BuildContext context, CartCubit cart, List<CartItem> items) {
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
                            onTap: () => _showClearCartDialog(context, cart),
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
                        ? WebCartEmptyState(
                            onChooseItems: () => _showChooseBouquetDialog(
                              context,
                              web: true,
                              title: 'Choose Bouquet',
                            ),
                          )
                        : LayoutBuilder(
                            builder: (context, rowConstraints) {
                              final sideWidth = (rowConstraints.maxWidth * 0.30)
                                  .clamp(280.0, 380.0);
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                          onMessage: () => Navigator.pushNamed(
                                            context,
                                            AppRoutes.addMessage,
                                            arguments: item.id,
                                          ),
                                          onRemove: () =>
                                              cart.removeItem(item.id),
                                          onIncrement: () =>
                                              cart.incrementQuantity(item.id),
                                          onDecrement: () =>
                                              cart.decrementQuantity(item.id),
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
                                          backgroundColor: AppColors.background,
                                          textColor: AppColors.primary,
                                          borderColor:
                                              AppColors.incrementButton,
                                          onPressed: () =>
                                              _showChooseBouquetDialog(
                                                context,
                                                web: true,
                                                title: 'Add More Items',
                                              ),
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
  }

  /// Mobile layout (unchanged).
  Widget _buildMobile(BuildContext context, CartCubit cart) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<CartCubit, CartState>(
          bloc: cart,
          builder: (context, state) {
            final items = cart.items;
            return Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
              child: Column(
                children: [
                  CustomAppBar.orchid(
                    title: 'my cart',
                    onBackPressed: onBackPressed,
                    actions: items.isEmpty
                        ? null
                        : [
                            AppBarAction(
                              icon: Ionicons.trash,
                              color: AppColors.error,
                              size: 22,
                              iconSize: 20,
                              onPressed: () {
                                _showClearCartDialog(context, cart);
                              },
                            ),
                          ],
                  ),
                  CustomText(
                    text: items.isEmpty
                        ? 'your chosen items'
                        : 'you have ${cart.totalItems} ${cart.totalItems == 1 ? 'item' : 'items'}',
                    fontFamily: AppFonts.goudyOldStyle,
                    fontSize: 18.sp,
                    textColor: AppColors.primary,
                  ),
                  SizedBox(height: 20.h),
                  Expanded(
                    child: items.isEmpty
                        ? _CartEmptyState(
                            onChooseItems: () => _showChooseBouquetDialog(
                              context,
                              web: false,
                              title: 'Choose Bouquet',
                            ),
                          )
                        : ListView.separated(
                            padding: EdgeInsets.only(bottom: 16.h),
                            itemCount: items.length,
                            separatorBuilder: (_, _) => SizedBox(height: 14.h),
                            itemBuilder: (context, index) {
                              final item = items[index];
                              return CartItemCard(
                                item: item,
                                onRemove: () => cart.removeItem(item.id),
                                onIncrement: () =>
                                    cart.incrementQuantity(item.id),
                                onDecrement: () =>
                                    cart.decrementQuantity(item.id),
                              );
                            },
                          ),
                  ),
                  if (items.isNotEmpty) ...[
                    CustomButton(
                      label: 'ADD MORE ITEMS',
                      fontFamily: AppFonts.goudyOldStyle,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      textColor: AppColors.primary,
                      backgroundColor: AppColors.background,
                      height: 48.h,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: AppColors.incrementButton,
                        width: 1.w,
                      ),
                      boxShadow: const [],
                      onPressed: () => _showChooseBouquetDialog(
                        context,
                        web: false,
                        title: 'Add More Items',
                      ),
                    ),
                    SizedBox(height: 12.h),
                    CheckoutSummary(
                      total: cart.totalPrice,
                      onConfirmOrder: onConfirmOrder,
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Opens the shared bouquet chooser so the user can buy an existing bouquet
  /// or create their own — used by both the empty cart and "add more items".
  void _showChooseBouquetDialog(
    BuildContext context, {
    required bool web,
    required String title,
  }) {
    showBouquetOptionsDialog(
      context,
      web: web,
      title: title,
      description: 'Buy an existing bouquet or create your own.',
      onBuyExisting: () =>
          Navigator.pushNamed(context, AppRoutes.chooseBouquets),
      onCreateCustom: () =>
          Navigator.pushNamed(context, AppRoutes.chooseFlowers),
    );
  }

  /// Shows a confirmation dialog before clearing the entire cart.
  void _showClearCartDialog(BuildContext context, CartCubit cart) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        // Desktop web presentation; dialogs have no LayoutBuilder, so the
        // desktop decision reads the real viewport. Narrow viewports keep the
        // untouched mobile dialog.
        if (isWideViewport(ctx)) {
          return WebClearCartDialog(
            onDeleteAll: () {
              cart.clearCart();
              Navigator.of(ctx).pop();
            },
            onCancel: () => Navigator.of(ctx).pop(),
          );
        }
        return PopScope(
          canPop: true,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            backgroundColor: AppColors.background,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64.r,
                    height: 64.r,
                    decoration: const BoxDecoration(
                      color: AppColors.redBackground,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Ionicons.trash,
                      size: 32.r,
                      color: AppColors.redText,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  CustomText(
                    text: 'Clear Cart',
                    textAlign: TextAlign.center,
                    fontFamily: AppFonts.goudyOldStyle,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    textColor: AppColors.redText,
                  ),
                  SizedBox(height: 8.h),
                  CustomText(
                    text:
                        'are you sure you want to remove all items '
                        'from your cart?\nthis action cannot be undone.',
                    textAlign: TextAlign.center,
                    fontSize: 14.sp,
                    textColor: AppColors.textPrimary,
                  ),
                  SizedBox(height: 24.h),
                  CustomButton(
                    label: 'Delete All',
                    height: 48.h,
                    borderRadius: BorderRadius.circular(14.r),
                    backgroundColor: AppColors.canceledText,
                    textColor: AppColors.white,
                    onPressed: () {
                      cart.clearCart();
                      Navigator.of(ctx).pop();
                    },
                  ),
                  SizedBox(height: 12.h),
                  CustomButton(
                    label: 'Cancel',
                    height: 48.h,
                    borderRadius: BorderRadius.circular(14.r),
                    backgroundColor: AppColors.textFieldDarkerPink,
                    textColor: AppColors.darkGreen,
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CartEmptyState extends StatelessWidget {
  final VoidCallback onChooseItems;

  const _CartEmptyState({required this.onChooseItems});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140.r,
            height: 140.r,
            decoration: BoxDecoration(
              color: AppColors.fieldPink,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Ionicons.cart_outline,
              size: 64.r,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 24.h),
          CustomText(
            text: 'Your cart is empty',
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 24.sp,
            fontWeight: FontWeight.w600,
            textColor: AppColors.black,
          ),
          SizedBox(height: 8.h),
          CustomText(
            text: 'Start adding your favorite items!',
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 16.sp,
            textColor: AppColors.textSecondary,
          ),
          SizedBox(height: 24.h),
          CustomButton(
            label: 'CHOOSE BOUQUET',
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            textColor: AppColors.black,
            backgroundColor: AppColors.textFieldPink,
            height: 52.h,
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: const [],
            onPressed: onChooseItems,
          ),
        ],
      ),
    );
  }
}
