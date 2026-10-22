import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text.dart';
import 'wallet_card.dart';
import 'wallet_provider.dart';

/// Mobile layout of the my-wallet screen (unchanged presentation).
class MyWalletMobileView extends StatelessWidget {
  final VoidCallback? onBackPressed;
  final WalletProvider? selectedProvider;
  final TextEditingController ownerNameController;
  final TextEditingController walletIdController;
  final TextEditingController balanceController;
  final ValueChanged<WalletProvider>? onProviderChanged;
  final VoidCallback onConfirm;

  const MyWalletMobileView({
    super.key,
    required this.onBackPressed,
    required this.selectedProvider,
    required this.ownerNameController,
    required this.walletIdController,
    required this.balanceController,
    required this.onProviderChanged,
    required this.onConfirm,
  });

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
                onBackPressed: onBackPressed,
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
                selectedProvider: selectedProvider,
                ownerNameController: ownerNameController,
                walletIdController: walletIdController,
                balanceController: balanceController,
                onProviderChanged: onProviderChanged,
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
                onPressed: onConfirm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
