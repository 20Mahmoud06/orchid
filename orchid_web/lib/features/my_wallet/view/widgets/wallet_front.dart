import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../shared/widgets/custom_text.dart';
import 'wallet_provider.dart';
import 'wallet_front_parts.dart';

class WalletFront extends StatelessWidget {
  const WalletFront({
    super.key,
    required this.walletName,
    required this.walletType,
    required this.ownerName,
    required this.maskedWalletId,
    required this.balance,
    required this.balanceVisible,
    required this.walletLogo,
    required this.onToggleBalance,
    required this.provider,
    required this.eyeAnimation,
    required this.isProviderSelected,
    required this.currency,
    this.onEditOwner,
    this.onEditWalletId,
    this.onEditBalance,
  });

  final String walletName;
  final String walletType;
  final String ownerName;
  final String maskedWalletId;
  final String balance;
  final bool balanceVisible;
  final Widget? walletLogo;
  final VoidCallback onToggleBalance;
  final WalletProvider provider;
  final Animation<double> eyeAnimation;
  final bool isProviderSelected;
  final String currency;
  final VoidCallback? onEditOwner;
  final VoidCallback? onEditWalletId;
  final VoidCallback? onEditBalance;

  @override
  Widget build(BuildContext context) {
    return WalletSurface(
      provider: provider,
      isProviderSelected: isProviderSelected,
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(22.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    LogoContainer(
                      provider: provider,
                      isProviderSelected: isProviderSelected,
                      child: walletLogo,
                    ),
                    SizedBox(width: 11.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: isProviderSelected ? walletName : 'Select a Provider',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            fontFamily: AppFonts.goudyOldStyle,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            textColor: isProviderSelected ? provider.brandColor : AppColors.textGrey,
                          ),
                          SizedBox(height: 3.h),
                          CustomText(
                            text: walletType,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            fontFamily: AppFonts.goudyOldStyle,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                            textColor: AppColors.textGrey,
                          ),
                        ],
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: isProviderSelected ? onToggleBalance : null,
                        borderRadius: BorderRadius.circular(18.r),
                        child: Padding(
                          padding: EdgeInsets.all(7.r),
                          child: Icon(
                            balanceVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: isProviderSelected
                                ? provider.brandColor
                                : AppColors.textGrey,
                            size: 20.r,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                CustomText(
                  text: 'AVAILABLE BALANCE',
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.3,
                  textColor: isProviderSelected
                      ? provider.brandColor.withValues(alpha: 0.7)
                      : AppColors.textGrey.withValues(alpha: 0.5),
                ),
                SizedBox(height: 4.h),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 450),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.3),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                        child: child,
                      ),
                    );
                  },
                  child: InkWell(
                    // We use the balanceVisible bool as the key to trigger the animation
                    key: ValueKey(balanceVisible),
                    onTap: isProviderSelected ? onEditBalance : null,
                    child: CustomText(
                      text: isProviderSelected ? balance : '$currency ••••••••',
                      fontFamily: AppFonts.goudyOldStyle,
                      fontSize: 29.sp,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.7,
                      textColor: isProviderSelected
                          ? provider.brandColor
                          : AppColors.textGrey.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                // 👆 END OF UPDATED BALANCE SECTION 👆

                SizedBox(height: 8.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: WalletIdentity(
                        label: 'WALLET OWNER',
                        value: isProviderSelected ? ownerName : '•••••••',
                        provider: provider,
                        isProviderSelected: isProviderSelected,
                        onTap: isProviderSelected ? onEditOwner : null,
                      ),
                    ),
                    Expanded(
                      child: WalletIdentity(
                        label: 'WALLET ID',
                        value: isProviderSelected ? maskedWalletId : '••••',
                        alignEnd: true,
                        provider: provider,
                        isProviderSelected: isProviderSelected,
                        onTap: isProviderSelected ? onEditWalletId : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}