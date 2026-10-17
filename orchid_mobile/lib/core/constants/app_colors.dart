import 'package:flutter/material.dart';

/// Centralized app colors for Orchid application based on design system specs.
abstract class AppColors {
  // Black
  static const Color black = Color(0xFF000000);

  // Primary & Brand Colors
  static const Color primary = Color(0xFF0F570C);

  // Background & Surface Colors
  static const Color background = Color(0xFFF9EFF6);
  static const Color surface = Colors.white;
  static const Color white = Colors.white;

  // Dark Green Typography & Brand Colors
  static const Color darkGreen = Color(0xFF1B4403);
  static const Color flowerShopGreen = Color(0xFF336A14);
  static const Color sideBarIcons = Color(0xFF1F3418);

  // Soft Pink UI Components
  static const Color fieldPink = Color(0xFFF5E4EB);
  static const Color bottomNavBar = Color(0xFFFee4e7);
  static const Color textFieldPink = Color(0xFFFFD2F1);
  static const Color textFieldDarkerPink = Color(0xFFFFC4ED);
  static const Color buttonPink = Color(0xFFF3C9D7);
  static const Color buttonPinkLight = Color(0xFFEDBDC3);
  static const Color authSection = Color(0xFFf8eef5);
  static const Color cardBorder = Color(0xFFF0A9C2);
  static const Color incrementButton = Color(0xFFFFB9E9);
  static const Color selectedCategory = Color(0xFFFF5692);
  static const Color thanksText = Color(0xFFCE4D7B);
  static const Color thanksYouText = Color(0xFFD64B7C);
  static const Color viewBouquetButton = Color(0xFF790305);

  // Design System Colors
  static const Color designFieldPink = Color(0xFFf5dbe7);
  static const Color privacyBackground = Color(0xFFFDE0E8);

  // Text & Action Colors
  static const Color linkPurple = Color(0xFF2a21d0);
  static const Color textPrimary = Color(0xFF605F5F);
  static const Color textSecondary = Color(0xFF555555);
  static const Color textGrey = Color(0xFF474444);
  static const Color textFieldText = Color(0xFF575356);
  static const Color iconColor = Color(0xFF6B6B6B);
  static const Color error = Color(0xFFD32F2F);
  static const Color redText = Color(0xFFF60101);

  // Validation Colors
  static const Color validationBorder = Color(0xFFE57373);
  static const Color redBackground = Color(0xFFF9B8B9);
  static const Color canceledText = Color(0xFFC6191C);
  static const Color yellowBackground = Color(0xFFF9F7B8);
  static const Color preparingText = Color(0xFF544809);
  static const Color greenBackground = Color(0xFFB8F9B9);

  // Wallet Provider Brand Colors
  static const Color walletVodafoneCash = Color(0xFFE60000);
  static const Color walletVodafoneCashLight = Color(0xFFFFD4D4);
  static const Color walletOrangeCash = Color(0xFFFF6600);
  static const Color walletOrangeCashLight = Color(0xFFFFE4C0);
  static const Color walletEtisalatCash = Color(0xFF7FBA00);
  static const Color walletEtisalatCashLight = Color(0xFFE8F5D0);
  static const Color walletWePay = Color(0xFF6B2FA0);
  static const Color walletWePayLight = Color(0xFFE8D8FF);

  // Field background with opacity (matches Figma design)
  static Color get fieldBackground => designFieldPink.withValues(alpha: 0.32);
}