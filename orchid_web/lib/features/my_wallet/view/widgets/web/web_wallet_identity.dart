import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_fonts.dart';
import '../../../../../shared/widgets/custom_text.dart';
import '../wallet_provider.dart';

/// Label + value block used for the wallet owner and wallet ID.
class WebWalletIdentity extends StatelessWidget {
  final String label;
  final String value;
  final WalletProvider provider;
  final bool isProviderSelected;
  final bool alignEnd;
  final VoidCallback? onTap;

  const WebWalletIdentity({
    super.key,
    required this.label,
    required this.value,
    required this.provider,
    required this.isProviderSelected,
    this.alignEnd = false,
    this.onTap,
  });

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
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
          textColor: isProviderSelected
              ? provider.brandColor.withValues(alpha: 0.6)
              : AppColors.textGrey.withValues(alpha: 0.4),
        ),
        const SizedBox(height: 5),
        CustomText(
          text: value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: alignEnd ? TextAlign.end : TextAlign.start,
          fontFamily: AppFonts.goudyOldStyle,
          fontSize: 13,
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
