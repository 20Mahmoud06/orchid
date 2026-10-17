import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../core/app_keys.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../features/auth/cubit/auth_cubit.dart';
import '../../../../features/checkout/checkout_flow.dart';
import '../../../../features/checkout/cubit/checkout_cubit.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text.dart';
import '../widgets/wallet_card.dart';

class MyWalletScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;

  const MyWalletScreen({
    super.key,
    this.onBackPressed,
  });

  @override
  State<MyWalletScreen> createState() => _MyWalletScreenState();
}

class _MyWalletScreenState extends State<MyWalletScreen> {
  final TextEditingController _ownerNameController = TextEditingController(text: 'Mahmoud Safa');
  final TextEditingController _walletIdController = TextEditingController(text: '4821');
  final TextEditingController _balanceController = TextEditingController(text: '0');

  @override
  void initState() {
    super.initState();
    _restoreWallet();
    _balanceController.addListener(_persistBalance);
  }

  @override
  void dispose() {
    _balanceController.removeListener(_persistBalance);
    _ownerNameController.dispose();
    _walletIdController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  /// Loads the saved balance and uses the signed-in user's phone number as the
  /// wallet ID (only its last four digits are ever shown).
  Future<void> _restoreWallet() async {
    final savedBalance =
        await AppPrefs.instance.getString(AppPrefKeys.walletBalance);
    final phone = AuthCubit.instance.userProfile?.phone ?? '';
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (!mounted) return;
    setState(() {
      if (savedBalance != null && savedBalance.isNotEmpty) {
        _balanceController.text = savedBalance;
      }
      if (digits.length >= 4) {
        _walletIdController.text = digits;
      }
    });
  }

  void _persistBalance() {
    AppPrefs.instance.saveString(
      AppPrefKeys.walletBalance,
      _balanceController.text,
    );
  }

  double get _walletBalance {
    final raw = _balanceController.text.trim().replaceAll(',', '');
    return double.tryParse(raw) ?? 0;
  }

  void _handleConfirm() {
    final total = CheckoutCubit.instance.totalPrice;
    final balance = _walletBalance;
    final messenger = ScaffoldMessenger.of(context);

    if (balance <= 0) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Your wallet balance is 0. Add money to your wallet to pay with it.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }

    if (balance < total) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'Insufficient wallet balance. Your balance is EGP '
              '${balance.toStringAsFixed(2)} but this order totals EGP '
              '${total.toDouble().toStringAsFixed(2)}.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }

    _showWalletConfirmationDialog(context);
  }

  Future<void> _showWalletConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (ctx) {
        return Dialog(
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
                  decoration: BoxDecoration(
                    color: AppColors.textFieldPink,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Ionicons.wallet_outline,
                    size: 32.r,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: 16.h),
                CustomText(
                  text: 'Confirm Wallet Payment',
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  textColor: AppColors.black,
                ),
                SizedBox(height: 12.h),
                CustomText(
                  text:
                      'The amount will be deducted from your wallet balance upon delivery. Do you want to confirm this order?',
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 14.sp,
                  textColor: AppColors.textPrimary,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        label: 'CANCEL',
                        fontFamily: AppFonts.goudyOldStyle,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        textColor: AppColors.black,
                        backgroundColor: AppColors.white,
                        height: 48.h,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: const [],
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: CustomButton(
                        label: 'CONFIRM',
                        fontFamily: AppFonts.goudyOldStyle,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        textColor: AppColors.black,
                        backgroundColor: AppColors.textFieldPink,
                        height: 48.h,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: const [],
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          submitCheckoutAndConfirm(
                            context,
                            paymentMethod: 'wallet',
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomAppBar.orchid(
                title: 'my wallet',
                onBackPressed: widget.onBackPressed,
                centerWidget: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomText(
                      text: 'my wallet',
                      fontFamily: AppFonts.goudyOldStyle,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w400,
                      textColor: AppColors.black,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              Image.asset(
                AppAssets.myWallet,
                width: 280.w,
                height: 220.h,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 20.h),
              WalletCard(
                walletLogo: const Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 22,
                ),
                initialBalanceVisible: false,
                ownerNameController: _ownerNameController,
                walletIdController: _walletIdController,
                balanceController: _balanceController,
                onProviderChanged: (provider) {
                  // provider changed callback
                },
                onBalanceVisibilityChanged: (isVisible) {
                  // balance visibility toggled
                },
              ),
              SizedBox(height: 140.h),
              CustomButton(
                label: 'CONFIRM',
                fontFamily: AppFonts.goudyOldStyle,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                textColor: AppColors.black,
                backgroundColor: AppColors.textFieldPink,
                height: 52.h,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: const [],
                onPressed: _handleConfirm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
