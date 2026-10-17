import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../core/utils/viewport.dart';
import '../../../../features/checkout/checkout_flow.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text.dart';
import '../widgets/bank_card_form.dart';
import '../widgets/bank_card_header.dart';
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
  // mobile [BankCardForm] keeps locally).
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
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          backgroundColor: AppColors.background,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 26.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60.r,
                  height: 60.r,
                  decoration: BoxDecoration(
                    color: AppColors.textFieldPink,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Ionicons.card_outline,
                    size: 30.r,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: 14.h),
                CustomText(
                  text: 'Confirm Card Payment',
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  textColor: AppColors.black,
                ),
                SizedBox(height: 10.h),
                CustomText(
                  text:
                      'You will be charged on the provided credit card upon delivery. Do you want to confirm this order?',
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 14.sp,
                  textColor: AppColors.textPrimary,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 22.h),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        label: 'CANCEL',
                        fontFamily: AppFonts.goudyOldStyle,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        textColor: AppColors.black,
                        backgroundColor: AppColors.white,
                        height: 48.h,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: const [],
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: CustomButton(
                        label: 'CONFIRM',
                        fontFamily: AppFonts.goudyOldStyle,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        textColor: AppColors.black,
                        backgroundColor: AppColors.textFieldPink,
                        height: 48.h,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: const [],
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          submitCheckoutAndConfirm(
                            context,
                            paymentMethod: 'card',
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
          return _buildWeb(context);
        }
        return _buildMobile(context);
      },
    );
  }

  /// Desktop-first "my bank card" page (>= 768px). Same colors, copy and
  /// behaviour as the mobile screen — a two-column layout like the other web
  /// checkout pages: the bank card fields on the left and the live card preview
  /// with the CONFIRM action in the sidebar.
  Widget _buildWeb(BuildContext context) {
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
                  WebBankCardHeader(onBackPressed: widget.onBackPressed),
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
                                      formKey: _bankFormKey,
                                      onChanged: _onCardChanged,
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
                                      cardNumber: _cardNumber,
                                      expiryDate: _expiryDate,
                                      cardHolderName: _cardHolderName,
                                      cvvCode: _cvvCode,
                                      showBackView: _isCvvFocused,
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
                                      onPressed: () {
                                        if (!_validateCard()) {
                                          return;
                                        }
                                        _showBankConfirmationDialog(context);
                                      },
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

  /// Mobile layout (unchanged).
  Widget _buildMobile(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(18.w, 10.h, 18.w, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomAppBar.orchid(
                    title: 'my bank card',
                    onBackPressed: widget.onBackPressed,
                    centerWidget: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomText(
                          text: 'my bank card',
                          fontFamily: AppFonts.goudyOldStyle,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w400,
                          textColor: AppColors.black,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  const BankCardHeader(),
                  SizedBox(height: 24.h),
                  BankCardForm(formKey: _bankFormKey),
                  SizedBox(height: 120.h),
                  CustomButton(
                    label: 'CONFIRM',
                    fontFamily: AppFonts.goudyOldStyle,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    textColor: AppColors.black,
                    backgroundColor: AppColors.textFieldPink,
                    height: 52.h,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: const [],
                    onPressed: () {
                      if (!_validateCard()) {
                        return;
                      }
                      _showBankConfirmationDialog(context);
                    },
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
