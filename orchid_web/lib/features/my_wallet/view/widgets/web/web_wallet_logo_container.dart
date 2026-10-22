import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../wallet_provider.dart';

/// Small rounded provider logo box, mirroring the mobile [LogoContainer].
class WebWalletLogoContainer extends StatelessWidget {
  final WalletProvider provider;
  final bool isProviderSelected;
  final Widget? child;

  const WebWalletLogoContainer({
    super.key,
    required this.provider,
    required this.isProviderSelected,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isProviderSelected
            ? provider.lightColor
            : AppColors.incrementButton.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isProviderSelected
              ? provider.brandColor.withValues(alpha: 0.3)
              : AppColors.incrementButton.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      alignment: Alignment.center,
      child:
          child ??
          Icon(
            isProviderSelected
                ? (provider.icon ?? Icons.account_balance_wallet_outlined)
                : Icons.account_balance_wallet_outlined,
            color: isProviderSelected
                ? provider.brandColor
                : AppColors.textGrey.withValues(alpha: 0.5),
            size: 23,
          ),
    );
  }
}
