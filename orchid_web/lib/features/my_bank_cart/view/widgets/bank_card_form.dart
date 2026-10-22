import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';

import '../../../../core/constants/app_colors.dart';
import 'bank_card_input_decoration.dart';

class BankCardForm extends StatefulWidget {
  const BankCardForm({super.key, this.onChanged, this.formKey});

  final void Function(CreditCardModel creditCardModel)? onChanged;

  /// Optional external key so callers can trigger validation (e.g. on a
  /// CONFIRM button that lives outside this form).
  final GlobalKey<FormState>? formKey;

  @override
  State<BankCardForm> createState() => _BankCardFormState();
}

class _BankCardFormState extends State<BankCardForm> {
  late final GlobalKey<FormState> formKey =
      widget.formKey ?? GlobalKey<FormState>();
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;

  void _onCreditCardModelChange(CreditCardModel creditCardModel) {
    setState(() {
      cardNumber = creditCardModel.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
    widget.onChanged?.call(creditCardModel);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CreditCardWidget(
          cardNumber: cardNumber,
          expiryDate: expiryDate,
          cardHolderName: cardHolderName,
          cvvCode: cvvCode,
          showBackView: isCvvFocused,
          onCreditCardWidgetChange: (brand) {},
          cardBgColor: AppColors.incrementButton,
          labelCardHolder: 'CARD HOLDER',
          isHolderNameVisible: true,
        ),
        CreditCardForm(
          formKey: formKey,
          onCreditCardModelChange: _onCreditCardModelChange,
          cardNumber: cardNumber,
          expiryDate: expiryDate,
          cardHolderName: cardHolderName,
          cvvCode: cvvCode,
          isCardHolderNameUpperCase: true,
          isHolderNameVisible: true,
          inputConfiguration: InputConfiguration(
            cardNumberDecoration: bankCardInputDecoration(
              label: 'Card Number',
              hint: 'XXXX XXXX XXXX XXXX',
            ),
            expiryDateDecoration: bankCardInputDecoration(
              label: 'Expired Date',
              hint: 'MM/YY',
            ),
            cvvCodeDecoration: bankCardInputDecoration(
              label: 'CVV',
              hint: 'XXX',
            ),
            cardHolderDecoration: bankCardInputDecoration(
              label: 'Card Holder',
              hint: 'Name as shown on card',
            ),
            cardNumberTextStyle: bankCardTextStyle,
            cardHolderTextStyle: bankCardTextStyle,
            expiryDateTextStyle: bankCardTextStyle,
            cvvCodeTextStyle: bankCardTextStyle,
          ),
        ),
      ],
    );
  }
}
