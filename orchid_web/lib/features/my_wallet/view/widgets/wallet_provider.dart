import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class WalletProvider {
  final String name;
  final String type;
  final Color brandColor;
  final Color lightColor;
  final IconData? icon;

  const WalletProvider({
    required this.name,
    required this.type,
    required this.brandColor,
    required this.lightColor,
    this.icon,
  });

  static const List<WalletProvider> providers = [
    WalletProvider(
      name: 'Vodafone Cash',
      type: 'Digital Wallet',
      brandColor: AppColors.walletVodafoneCash,
      lightColor: AppColors.walletVodafoneCashLight,
      icon: Icons.phone_android,
    ),
    WalletProvider(
      name: 'Orange Cash',
      type: 'Digital Wallet',
      brandColor: AppColors.walletOrangeCash,
      lightColor: AppColors.walletOrangeCashLight,
      icon: Icons.phone_iphone,
    ),
    WalletProvider(
      name: 'Etisalat Cash',
      type: 'Digital Wallet',
      brandColor: AppColors.walletEtisalatCash,
      lightColor: AppColors.walletEtisalatCashLight,
      icon: Icons.phone_locked,
    ),
    WalletProvider(
      name: 'WE Pay',
      type: 'Digital Wallet',
      brandColor: AppColors.walletWePay,
      lightColor: AppColors.walletWePayLight,
      icon: Icons.phone_in_talk,
    ),
  ];

  static WalletProvider fromName(String name) {
    return providers.firstWhere(
      (p) => p.name == name,
      orElse: () => providers.first,
    );
  }
}
