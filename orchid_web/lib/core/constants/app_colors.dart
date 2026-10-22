import 'package:flutter/material.dart';

/// Centralized app colors for Orchid application based on design system specs.
abstract class AppColors {
  // Black
  static const Color black = Color(0xFF000000);

  // Primary & Brand Colors
  static const Color primary = Color(0xFF0F570C);
  static const Color deepGreen = Color(0xFF093B07);

  // Web authentication neutrals
  static const Color ink = Color(0xFF252525);
  static const Color pinkBorder = Color(0xFFE6CFD7);

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

  // Web storefront palette (desktop reference design; Home, top nav, footer)
  static const Color storeDeepGreen = Color(0xFF1E352D);
  static const Color storeBlush = Color(0xFFFCEEEB);
  static const Color storeBlushBorder = Color(0xFFF5E1DC);
  static const Color storeEyebrow = Color(0xFF677870);
  static const Color storeBodyText = Color(0xFF4A5C54);
  static const Color storeGreenHover = Color(0xFF2C4C41);
  static const Color storeOutlineBorder = Color(0xFFE5D5D3);
  static const Color storeDivider = Color(0xFFD6C8C5);
  static const Color storeIconMuted = Color(0xFF7A6B69);
  static const Color storeHintText = Color(0xFF9E8E8C);
  static const Color storeCircleBg = Color(0xFFFDEEF0);
  static const Color storeCircleBorder = Color(0xFFF3DADB);
  static const Color storeLabel = Color(0xFF2B3D35);
  static const Color storeCardBorder = Color(0xFFEFE6E3);
  static const Color storeHairline = Color(0xFFF0E5E2);
  static const Color storeNavText = Color(0xFF2C3E36);
  static const Color storeRose = Color(0xFFC76978);
  static const Color storeFooterText = Color(0xFF6B7B73);
  static const Color announcementText = Color(0xFF6B5555);

  // Disabled form field fill
  static const Color fieldDisabledPink = Color(0xFFF7F3F5);

  // Field background with opacity (matches Figma design)
  static Color get fieldBackground => designFieldPink.withValues(alpha: 0.32);
}
