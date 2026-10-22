import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../shared/widgets/custom_text.dart';

class AddMessageHeader extends StatelessWidget {
  final VoidCallback? onBackPressed;

  const AddMessageHeader({super.key, this.onBackPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30.r,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: CustomText(
              text: 'Add a message',
              fontFamily: AppFonts.goudyOldStyle,
              fontSize: 24.sp,
              fontWeight: FontWeight.w400,
              textColor: AppColors.black,
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 30.r,
              height: 30.r,
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: SizedBox(
                  width: 24.r,
                  height: 24.r,
                  child: Image.asset(
                    AppAssets.backButtonIcon,
                    fit: BoxFit.contain,
                  ),
                ),
                onPressed:
                    onBackPressed ??
                    () {
                      if (Navigator.canPop(context)) {
                        Navigator.maybePop(context);
                      }
                    },
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 24.r,
              height: 24.r,
              child: Image.asset(AppAssets.messageIcon, fit: BoxFit.contain),
            ),
          ),
        ],
      ),
    );
  }
}
