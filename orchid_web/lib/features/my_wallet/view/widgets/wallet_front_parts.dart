import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../shared/widgets/custom_text.dart';
import 'wallet_provider.dart';

class WalletSurface extends StatelessWidget {
  const WalletSurface({
    super.key,
    required this.child,
    required this.provider,
    required this.isProviderSelected,
  });

  final Widget child;
  final WalletProvider provider;
  final bool isProviderSelected;

  @override
  Widget build(BuildContext context) {
    final Color borderColor = isProviderSelected
        ? provider.brandColor.withValues(alpha: 0.6)
        : AppColors.incrementButton;
    final Color shadowColor = isProviderSelected
        ? provider.brandColor.withValues(alpha: 0.15)
        : AppColors.incrementButton.withValues(alpha: 0.1);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: borderColor,
          width: isProviderSelected ? 2.w : 1.5.w,
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: isProviderSelected ? 22.r : 10.r,
            offset: Offset(0, 11.h),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class LogoContainer extends StatelessWidget {
  const LogoContainer({
    super.key,
    required this.provider,
    required this.isProviderSelected,
    required this.child,
  });

  final WalletProvider provider;
  final bool isProviderSelected;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      width: 35.r,
      height: 35.r,
      decoration: BoxDecoration(
        color: isProviderSelected
            ? provider.lightColor
            : AppColors.incrementButton.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(
          color: isProviderSelected
              ? provider.brandColor.withValues(alpha: 0.3)
              : AppColors.incrementButton.withValues(alpha: 0.2),
          width: 1.5.w,
        ),
      ),
      alignment: Alignment.center,
      child:
          child ??
          Icon(
            isProviderSelected
                ? (provider.icon ?? Icons.account_balance_wallet_outlined)
                : Icons.account_balance_wallet_outlined,
            color: isProviderSelected
                ? provider.brandColor
                : AppColors.textGrey.withValues(alpha: 0.5),
            size: 23.r,
          ),
    );
  }
}

class WalletIdentity extends StatelessWidget {
  const WalletIdentity({
    super.key,
    required this.label,
    required this.value,
    required this.provider,
    required this.isProviderSelected,
    this.alignEnd = false,
    this.onTap,
  });

  final String label;
  final String value;
  final WalletProvider provider;
  final bool isProviderSelected;
  final bool alignEnd;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        CustomText(
          text: label,
          fontFamily: AppFonts.goudyOldStyle,
          fontSize: 8.sp,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
          textColor: isProviderSelected
              ? provider.brandColor.withValues(alpha: 0.6)
              : AppColors.textGrey.withValues(alpha: 0.4),
        ),
        SizedBox(height: 5.h),
        CustomText(
          text: value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: alignEnd ? TextAlign.end : TextAlign.start,
          fontFamily: AppFonts.goudyOldStyle,
          fontSize: 13.sp,
          fontWeight: FontWeight.w700,
          textColor: isProviderSelected
              ? provider.brandColor
              : AppColors.textGrey.withValues(alpha: 0.4),
        ),
      ],
    );

    if (onTap == null) {
      return content;
    }

    return InkWell(onTap: onTap, child: content);
  }
}
