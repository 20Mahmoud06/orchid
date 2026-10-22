import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_fonts.dart';
import '../../../../../shared/widgets/custom_button.dart';
import '../wallet_provider.dart';
import 'web_wallet_widgets.dart';

/// Desktop-first "my wallet" page (>= 768px): wallet illustration on the left
/// and the wallet card with the CONFIRM action in the sidebar.
class MyWalletWebView extends StatelessWidget {
  final VoidCallback? onBackPressed;
  final WalletProvider? selectedProvider;
  final TextEditingController ownerNameController;
  final TextEditingController walletIdController;
  final TextEditingController balanceController;
  final ValueChanged<WalletProvider>? onProviderChanged;
  final VoidCallback onConfirm;

  const MyWalletWebView({
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
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(40, 36, 40, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  WebWalletHeader(onBackPressed: onBackPressed),
                  const SizedBox(height: 24),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, rowConstraints) {
                        final sideWidth = (rowConstraints.maxWidth * 0.40)
                            .clamp(360.0, 440.0);
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    const SizedBox(height: 12),
                                    Center(
                                      child: Image.asset(
                                        AppAssets.myWallet,
                                        width: 460,
                                        height: 340,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 28),
                            SizedBox(
                              width: sideWidth,
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    WebWalletCard(
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
                                    const SizedBox(height: 20),
                                    CustomButton(
                                      label: 'CONFIRM',
                                      fontFamily: AppFonts.goudyOldStyle,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      textColor: AppColors.black,
                                      backgroundColor: AppColors.textFieldPink,
                                      height: 52,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: const [],
                                      onPressed: onConfirm,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
