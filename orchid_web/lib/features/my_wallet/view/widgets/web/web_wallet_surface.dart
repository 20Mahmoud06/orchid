import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../wallet_provider.dart';

/// White rounded surface of the wallet card, matching the mobile
/// [WalletSurface] at fixed logical pixels.
class WebWalletSurface extends StatelessWidget {
  final Widget child;
  final WalletProvider provider;
  final bool isProviderSelected;

  const WebWalletSurface({
    super.key,
    required this.child,
    required this.provider,
    required this.isProviderSelected,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isProviderSelected
        ? provider.brandColor.withValues(alpha: 0.6)
        : AppColors.incrementButton;
    final shadowColor = isProviderSelected
        ? provider.brandColor.withValues(alpha: 0.15)
        : AppColors.incrementButton.withValues(alpha: 0.1);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: borderColor,
          width: isProviderSelected ? 2 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: isProviderSelected ? 22 : 10,
            offset: const Offset(0, 11),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}
