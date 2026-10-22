import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text.dart';
import '../widgets/bank_card_form.dart';
import '../widgets/bank_card_header.dart';

/// Mobile layout of the "my bank card" page (unchanged presentation).
class MyBankCartMobileView extends StatelessWidget {
  final VoidCallback? onBackPressed;
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final GlobalKey<FormState> formKey;
  final VoidCallback onConfirm;

  const MyBankCartMobileView({
    super.key,
    required this.onBackPressed,
    required this.fadeAnimation,
    required this.slideAnimation,
    required this.formKey,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(18.w, 10.h, 18.w, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomAppBar.orchid(
                    title: 'my bank card',
                    onBackPressed: onBackPressed,
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
                  BankCardForm(formKey: formKey),
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
                    onPressed: onConfirm,
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
