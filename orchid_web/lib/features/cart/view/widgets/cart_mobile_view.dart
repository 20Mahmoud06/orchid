import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart' show CustomButton;
import '../../../../shared/widgets/custom_text.dart';
import '../../cubit/cart_cubit.dart';
import '../../cubit/cart_state.dart';
import 'cart_item_card.dart';
import 'checkout_summary.dart';

/// Mobile layout of the cart screen (unchanged presentation).
class CartMobileView extends StatelessWidget {
  final VoidCallback? onBackPressed;
  final VoidCallback? onConfirmOrder;
  final VoidCallback onClearCart;
  final VoidCallback onChooseItems;
  final VoidCallback onAddMoreItems;

  const CartMobileView({
    super.key,
    required this.onBackPressed,
    required this.onConfirmOrder,
    required this.onClearCart,
    required this.onChooseItems,
    required this.onAddMoreItems,
  });

  @override
  Widget build(BuildContext context) {
    final cart = CartCubit.instance;

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
                              onPressed: onClearCart,
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
                        ? _CartEmptyState(onChooseItems: onChooseItems)
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
                      onPressed: onAddMoreItems,
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
