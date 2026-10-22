import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_text.dart';
import 'wallet_provider.dart';

/// Closed-state field showing the selected wallet provider.
class WalletProviderDropdownTrigger extends StatelessWidget {
  final WalletProvider? selectedProvider;
  final String hintText;
  final bool isMenuOpen;
  final VoidCallback onTap;

  const WalletProviderDropdownTrigger({
    super.key,
    required this.selectedProvider,
    required this.hintText,
    required this.isMenuOpen,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = selectedProvider != null;
    final Color borderColor = isSelected
        ? selectedProvider!.brandColor.withValues(alpha: 0.35)
        : AppColors.incrementButton;
    final Color textColor = isSelected
        ? selectedProvider!.brandColor
        : AppColors.textGrey;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: borderColor, width: isSelected ? 2.w : 1.5.w),
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: selectedProvider!.brandColor.withValues(alpha: 0.12),
              blurRadius: 12.r,
              offset: Offset(0, 6.h),
            ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
          child: Row(
            children: [
              Container(
                width: 32.r,
                height: 32.r,
                decoration: BoxDecoration(
                  color: isSelected
                      ? selectedProvider!.lightColor
                      : AppColors.incrementButton.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: isSelected
                        ? selectedProvider!.brandColor.withValues(alpha: 0.25)
                        : AppColors.incrementButton.withValues(alpha: 0.25),
                  ),
                ),
                child: Icon(
                  isSelected
                      ? (selectedProvider!.icon ??
                            Icons.account_balance_wallet_outlined)
                      : Icons.account_balance_wallet_outlined,
                  color: isSelected
                      ? selectedProvider!.brandColor
                      : AppColors.textGrey,
                  size: 18.r,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.1, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: isSelected
                      ? CustomText(
                          key: ValueKey(selectedProvider!.name),
                          text: selectedProvider!.name,
                          textColor: textColor,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        )
                      : CustomText(
                          key: ValueKey(hintText),
                          text: hintText,
                          textColor: AppColors.textGrey,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                ),
              ),
              AnimatedRotation(
                turns: isMenuOpen ? 0.5 : 0,
                duration: const Duration(milliseconds: 250),
                child: Container(
                  padding: EdgeInsets.all(6.r),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? selectedProvider!.lightColor.withValues(alpha: 0.4)
                        : AppColors.incrementButton.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.arrow_drop_down,
                    color: isSelected
                        ? selectedProvider!.brandColor
                        : AppColors.textGrey,
                    size: 24.r,
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
