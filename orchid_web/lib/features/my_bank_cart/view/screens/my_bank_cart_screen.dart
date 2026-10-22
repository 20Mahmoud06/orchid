import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';

import '../../../../core/utils/viewport.dart';
import '../../../../features/checkout/checkout_flow.dart';
import '../widgets/bank_card_confirmation_dialog.dart';
import '../widgets/my_bank_cart_mobile_view.dart';
import '../widgets/web/my_bank_cart_web_view.dart';
import '../widgets/web/web_bank_card_widgets.dart';

class MyBankCartScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;

  const MyBankCartScreen({super.key, this.onBackPressed});

  @override
  State<MyBankCartScreen> createState() => _MyBankCartScreenState();
}

class _MyBankCartScreenState extends State<MyBankCartScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  final GlobalKey<FormState> _bankFormKey = GlobalKey<FormState>();

  // Live card preview state for the desktop web layout (mirrors what the
  // mobile bank card form keeps locally).
  String _cardNumber = '';
  String _expiryDate = '';
  String _cardHolderName = '';
  String _cvvCode = '';
  bool _isCvvFocused = false;

  void _onCardChanged(CreditCardModel creditCardModel) {
    setState(() {
      _cardNumber = creditCardModel.cardNumber;
      _expiryDate = creditCardModel.expiryDate;
      _cardHolderName = creditCardModel.cardHolderName;
      _cvvCode = creditCardModel.cvvCode;
      _isCvvFocused = creditCardModel.isCvvFocused;
    });
  }

  bool _validateCard() {
    final formState = _bankFormKey.currentState;
    if (formState == null) {
      return false;
    }
    return formState.validate();
  }

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onConfirm(BuildContext context) {
    if (!_validateCard()) {
      return;
    }
    _showBankConfirmationDialog(context);
  }

  void _showBankConfirmationDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        // The web build pins `MediaQuery.size` to the phone design size, so the
        // desktop decision has to read the real viewport. Mobile is unchanged.
        if (isWideViewport(ctx)) {
          return WebBankCardConfirmationDialog(
            onCancel: () => Navigator.of(ctx).pop(),
            onConfirm: () {
              Navigator.of(ctx).pop();
              submitCheckoutAndConfirm(context, paymentMethod: 'card');
            },
          );
        }
        return BankCardConfirmationDialog(
          onCancel: () => Navigator.of(ctx).pop(),
          onConfirm: () {
            Navigator.of(ctx).pop();
            submitCheckoutAndConfirm(context, paymentMethod: 'card');
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Desktop-first web presentation (>= 768px). Narrow viewports keep the
        // untouched Orchid mobile layout.
        if (constraints.maxWidth >= 768) {
          return MyBankCartWebView(
            onBackPressed: widget.onBackPressed,
            formKey: _bankFormKey,
            cardNumber: _cardNumber,
            expiryDate: _expiryDate,
            cardHolderName: _cardHolderName,
            cvvCode: _cvvCode,
            isCvvFocused: _isCvvFocused,
            onCardChanged: _onCardChanged,
            onConfirm: () => _onConfirm(context),
          );
        }
        return MyBankCartMobileView(
          onBackPressed: widget.onBackPressed,
          fadeAnimation: _fadeAnimation,
          slideAnimation: _slideAnimation,
          formKey: _bankFormKey,
          onConfirm: () => _onConfirm(context),
        );
      },
    );
  }
}
