import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_fonts.dart';
import '../../../../../shared/widgets/custom_button.dart';
import '../../../models/payment_method.dart';
import 'web_payment_widgets.dart';

/// Desktop-first payment page (>= 768px). Same colors, copy and behaviour as
/// the mobile screen — a two-column layout like "my cart": the payment
/// illustration on the left and the three method cards on the right, with the
/// CONFIRM action centered below both columns.
class PaymentWebView extends StatelessWidget {
  final PaymentMethod selected;
  final ValueChanged<PaymentMethod> onMethodSelected;
  final VoidCallback onConfirm;
  final VoidCallback? onBackPressed;

  const PaymentWebView({
    super.key,
    required this.selected,
    required this.onMethodSelected,
    required this.onConfirm,
    required this.onBackPressed,
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
                  WebPaymentHeader(onBackPressed: onBackPressed),
                  const SizedBox(height: 24),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, rowConstraints) {
                        final sideWidth = (rowConstraints.maxWidth * 0.30)
                            .clamp(280.0, 380.0);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Expanded(
                                    child: SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          WebPaymentIllustrationCard(),
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
                                            CrossAxisAlignment.start,
                                        children: [
                                          WebPaymentMethodCard(
                                            icon: Ionicons.cash_outline,
                                            label: 'cash',
                                            isSelected:
                                                selected == PaymentMethod.cash,
                                            onTap: () => onMethodSelected(
                                              PaymentMethod.cash,
                                            ),
                                          ),
                                          const SizedBox(height: 18),
                                          WebPaymentMethodCard(
                                            customIcon: Image.asset(
                                              selected == PaymentMethod.card
                                                  ? AppAssets.visaBlackIcon
                                                  : AppAssets.visaGreyIcon,
                                              width: 30,
                                              height: 30,
                                            ),
                                            label: 'credit \\ debit card',
                                            isSelected:
                                                selected == PaymentMethod.card,
                                            onTap: () => onMethodSelected(
                                              PaymentMethod.card,
                                            ),
                                          ),
                                          const SizedBox(height: 18),
                                          WebPaymentMethodCard(
                                            icon: Ionicons.wallet_outline,
                                            label: 'wallet',
                                            isSelected:
                                                selected ==
                                                PaymentMethod.wallet,
                                            onTap: () => onMethodSelected(
                                              PaymentMethod.wallet,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Center(
                              child: SizedBox(
                                width: 320,
                                child: CustomButton(
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
