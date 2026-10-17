import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_fonts.dart';
import '../../../../../shared/widgets/custom_text.dart';

/// Desktop-first building blocks for the "my bank card" page.
///
/// Presentation only: the colors, copy and behaviour mirror the mobile screen
/// exactly, sized in fixed logical pixels (the web app pins the design size, so
/// these render 1:1 on any monitor — the same convention as the other web
/// pages).

/// Centered "my bank card" title (same copy as the mobile app bar).
class WebBankCardHeader extends StatelessWidget {
  final VoidCallback? onBackPressed;

  const WebBankCardHeader({super.key, this.onBackPressed});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 36,
      child: Center(
        child: CustomText(
          text: 'my bank card',
          fontFamily: AppFonts.goudyOldStyle,
          fontSize: 24,
          textColor: AppColors.black,
        ),
      ),
    );
  }
}

/// "Add your bank card" heading and subtitle, matching the mobile
/// [BankCardHeader] at fixed logical pixels.
class WebBankCardInfo extends StatelessWidget {
  const WebBankCardInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: 'Add your bank card',
          fontFamily: AppFonts.goudyOldStyle,
          fontSize: 23,
          fontWeight: FontWeight.w800,
          textColor: AppColors.darkGreen,
        ),
        SizedBox(height: 6),
        CustomText(
          text: 'Securely save a card for faster payments.',
          fontFamily: AppFonts.inriaSerif,
          fontSize: 14,
          textColor: AppColors.textPrimary,
        ),
      ],
    );
  }
}

/// Text style for the bank card input fields (fixed logical pixels).
const TextStyle webBankCardTextStyle = TextStyle(
  color: AppColors.textFieldText,
  fontSize: 15,
  fontFamily: AppFonts.goudyOldStyle,
);

/// Styled input decoration for the bank card form fields, mirroring the mobile
/// [bankCardInputDecoration] with fixed logical pixels.
InputDecoration webBankCardInputDecoration({
  required String label,
  required String hint,
}) {
  OutlineInputBorder buildBorder(Color color, double width) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  return InputDecoration(
    labelText: label,
    hintText: hint,
    labelStyle: TextStyle(
      color: AppColors.darkGreen.withValues(alpha: 0.7),
      fontSize: 14,
      fontWeight: FontWeight.w600,
      fontFamily: AppFonts.goudyOldStyle,
    ),
    hintStyle: TextStyle(
      color: AppColors.darkGreen.withValues(alpha: 0.45),
      fontSize: 15,
      fontFamily: AppFonts.goudyOldStyle,
    ),
    filled: true,
    fillColor: AppColors.background,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
    border: buildBorder(AppColors.cardBorder, 1),
    enabledBorder: buildBorder(AppColors.cardBorder, 1),
    focusedBorder: buildBorder(AppColors.selectedCategory, 2),
    disabledBorder: buildBorder(
      AppColors.cardBorder.withValues(alpha: 0.45),
      1,
    ),
    errorBorder: buildBorder(AppColors.error, 1),
    focusedErrorBorder: buildBorder(AppColors.error, 2),
  );
}

/// The card number / expiry / cvv / holder fields, matching the mobile
/// [BankCardForm] form section at fixed logical pixels.
class WebBankCardForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final void Function(CreditCardModel creditCardModel)? onChanged;

  const WebBankCardForm({super.key, required this.formKey, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return CreditCardForm(
      formKey: formKey,
      onCreditCardModelChange: (creditCardModel) =>
          onChanged?.call(creditCardModel),
      cardNumber: '',
      expiryDate: '',
      cardHolderName: '',
      cvvCode: '',
      isCardHolderNameUpperCase: true,
      isHolderNameVisible: true,
      inputConfiguration: InputConfiguration(
        cardNumberDecoration: webBankCardInputDecoration(
          label: 'Card Number',
          hint: 'XXXX XXXX XXXX XXXX',
        ),
        expiryDateDecoration: webBankCardInputDecoration(
          label: 'Expired Date',
          hint: 'MM/YY',
        ),
        cvvCodeDecoration: webBankCardInputDecoration(
          label: 'CVV',
          hint: 'XXX',
        ),
        cardHolderDecoration: webBankCardInputDecoration(
          label: 'Card Holder',
          hint: 'Name as shown on card',
        ),
        cardNumberTextStyle: webBankCardTextStyle,
        cardHolderTextStyle: webBankCardTextStyle,
        expiryDateTextStyle: webBankCardTextStyle,
        cvvCodeTextStyle: webBankCardTextStyle,
      ),
    );
  }
}

/// Live preview of the card being entered, matching the mobile
/// [CreditCardWidget] styling.
class WebBankCardPreview extends StatelessWidget {
  final String cardNumber;
  final String expiryDate;
  final String cardHolderName;
  final String cvvCode;
  final bool showBackView;

  const WebBankCardPreview({
    super.key,
    required this.cardNumber,
    required this.expiryDate,
    required this.cardHolderName,
    required this.cvvCode,
    required this.showBackView,
  });

  @override
  Widget build(BuildContext context) {
    // [CreditCardWidget] sizes itself to half the screen height in landscape
    // (the library's `CardBackground` fallback), which on a desktop monitor
    // makes the card enormous and pushes the CONFIRM action off-screen. Pin an
    // explicit height that matches the card's portrait aspect ratio instead.
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return CreditCardWidget(
          cardNumber: cardNumber,
          expiryDate: expiryDate,
          cardHolderName: cardHolderName,
          cvvCode: cvvCode,
          showBackView: showBackView,
          onCreditCardWidgetChange: (brand) {},
          cardBgColor: AppColors.incrementButton,
          labelCardHolder: 'CARD HOLDER',
          isHolderNameVisible: true,
          height: (width - 32) * 0.5714,
        );
      },
    );
  }
}

/// Modal shown when the shopper confirms a card payment. Same copy as the
/// mobile dialog, sized like the other desktop web dialogs (fixed logical
/// pixels, maxWidth 440).
class WebBankCardConfirmationDialog extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const WebBankCardConfirmationDialog({
    super.key,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.background,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.textFieldPink,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Ionicons.card_outline,
                  size: 32,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Confirm Card Payment',
                style: TextStyle(
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'You will be charged on the provided credit card upon delivery. Do you want to confirm this order?',
                style: TextStyle(
                  fontFamily: AppFonts.inriaSerif,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textFieldPink,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'CONFIRM',
                    style: TextStyle(
                      fontFamily: AppFonts.goudyOldStyle,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.storeOutlineBorder),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'CANCEL',
                    style: TextStyle(
                      fontFamily: AppFonts.goudyOldStyle,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
