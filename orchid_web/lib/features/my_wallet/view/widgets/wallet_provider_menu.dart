import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_text.dart';
import 'wallet_provider.dart';

/// Scrollable overlay panel listing every wallet provider.
class WalletProviderMenu extends StatelessWidget {
  final WalletProvider? selectedProvider;
  final double width;
  final double maxHeight;
  final ValueChanged<WalletProvider> onSelected;

  const WalletProviderMenu({
    super.key,
    required this.selectedProvider,
    required this.width,
    required this.maxHeight,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      color: Colors.white,
      borderRadius: BorderRadius.circular(18.r),
      clipBehavior: Clip.antiAlias,
      child: Container(
        constraints: BoxConstraints(maxHeight: maxHeight),
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: AppColors.incrementButton.withValues(alpha: 0.1),
          ),
        ),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final provider in WalletProvider.providers)
                _WalletProviderMenuOption(
                  provider: provider,
                  isSelected: selectedProvider?.name == provider.name,
                  onTap: () => onSelected(provider),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WalletProviderMenuOption extends StatelessWidget {
  final WalletProvider provider;
  final bool isSelected;
  final VoidCallback onTap;

  const _WalletProviderMenuOption({
    required this.provider,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        width: double.infinity,
        decoration: BoxDecoration(
          color: isSelected
              ? provider.lightColor.withValues(alpha: 0.25)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Row(
          children: [
            Container(
              width: 32.r,
              height: 32.r,
              decoration: BoxDecoration(
                color: provider.lightColor,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: provider.brandColor.withValues(alpha: 0.25),
                ),
              ),
              child: Icon(
                provider.icon ?? Icons.phone_android,
                color: provider.brandColor,
                size: 18.r,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: CustomText(
                text: provider.name,
                textColor: isSelected
                    ? provider.brandColor
                    : AppColors.textGrey,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 14.sp,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isSelected)
              Container(
                padding: EdgeInsets.all(4.r),
                decoration: BoxDecoration(
                  color: provider.brandColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: provider.brandColor,
                  size: 18.r,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
