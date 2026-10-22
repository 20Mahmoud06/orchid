import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_fonts.dart';
import '../../../../../shared/widgets/custom_button.dart';
import 'web_bank_card_widgets.dart';

/// Desktop-first "my bank card" page (>= 768px). Same colors, copy and
/// behaviour as the mobile screen — a two-column layout like the other web
/// checkout pages: the bank card fields on the left and the live card preview
/// with the CONFIRM action in the sidebar.
class MyBankCartWebView extends StatelessWidget {
  final VoidCallback? onBackPressed;
  final GlobalKey<FormState> formKey;
  final String cardNumber;
  final String expiryDate;
  final String cardHolderName;
  final String cvvCode;
  final bool isCvvFocused;
  final ValueChanged<CreditCardModel> onCardChanged;
  final VoidCallback onConfirm;

  const MyBankCartWebView({
    super.key,
    required this.onBackPressed,
    required this.formKey,
    required this.cardNumber,
    required this.expiryDate,
    required this.cardHolderName,
    required this.cvvCode,
    required this.isCvvFocused,
    required this.onCardChanged,
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
                  WebBankCardHeader(onBackPressed: onBackPressed),
                  const SizedBox(height: 24),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, rowConstraints) {
                        final sideWidth = (rowConstraints.maxWidth * 0.36)
                            .clamp(300.0, 400.0);
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const WebBankCardInfo(),
                                    const SizedBox(height: 20),
                                    WebBankCardForm(
                                      formKey: formKey,
                                      onChanged: onCardChanged,
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
                                    WebBankCardPreview(
                                      cardNumber: cardNumber,
                                      expiryDate: expiryDate,
                                      cardHolderName: cardHolderName,
                                      cvvCode: cvvCode,
                                      showBackView: isCvvFocused,
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
