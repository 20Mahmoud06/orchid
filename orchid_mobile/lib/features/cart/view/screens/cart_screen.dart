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
import '../widgets/cart_dialogs.dart';
import '../widgets/cart_empty_state.dart';
import '../widgets/cart_item_list.dart';
import '../widgets/checkout_summary.dart';

/// Cart screen listing the user's added items with a checkout summary.
class CartScreen extends StatelessWidget {
  final VoidCallback? onBackPressed;
  final VoidCallback? onConfirmOrder;

  const CartScreen({super.key, this.onBackPressed, this.onConfirmOrder});

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
                              onPressed: () {
                                showClearCartDialog(context, cart);
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
                        ? CartEmptyState(
                            onChooseItems: () => showChooseBouquetDialog(
                              context,
                              title: 'Choose Bouquet',
                            ),
                          )
                        : CartItemList(items: items, cart: cart),
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
                      onPressed: () => showChooseBouquetDialog(
                        context,
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
}
