import 'package:flutter/material.dart';

import 'package:ORCHID/core/constants/app_colors.dart';
import 'package:ORCHID/core/constants/app_fonts.dart';
import 'package:ORCHID/features/auth/data/models/user_profile_model.dart';

import 'web_profile_card_avatar.dart';
import 'web_profile_info_grid.dart';
import '../../../../../shared/widgets/custom_text.dart';

/// The rounded profile card: avatar, name/email, an Edit button and the info
/// fields laid out as a two-column grid on wide screens.
class WebProfileCard extends StatelessWidget {
  final String displayName;
  final String displayEmail;
  final String? imageUrl;
  final UserProfileModel? profile;
  final VoidCallback onEdit;

  const WebProfileCard({
    super.key,
    required this.displayName,
    required this.displayEmail,
    required this.imageUrl,
    required this.profile,
    required this.onEdit,
  });

  String _displayValue(String? value) {
    if (value == null || value.trim().isEmpty) return '-';
    return value.trim();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              WebProfileCardAvatar(imageUrl: imageUrl, onTap: onEdit),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: displayName,
                      fontFamily: AppFonts.goudyOldStyle,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      textColor: AppColors.black,
                    ),
                    const SizedBox(height: 2),
                    CustomText(
                      text: displayEmail,
                      fontFamily: AppFonts.goudyOldStyle,
                      fontSize: 13,
                      textColor: Colors.black.withValues(alpha: 0.75),
                    ),
                    const SizedBox(height: 10),
                    _WebProfileEditButton(onTap: onEdit),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(color: AppColors.cardBorder, height: 1),
          const SizedBox(height: 20),
          WebProfileInfoGrid(
            children: [
              WebProfileInfoField(
                label: 'Username',
                value: _displayValue(profile?.username),
              ),
              WebProfileInfoField(
                label: 'Phone Number',
                value: _displayValue(profile?.phone),
              ),
              WebProfileInfoField(
                label: 'Whatsapp Number',
                value: _displayValue(profile?.whatsapp),
              ),
              WebProfileInfoField(
                label: 'Delivery Address',
                value: _displayValue(profile?.address),
                showArrow: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WebProfileEditButton extends StatelessWidget {
  final VoidCallback onTap;

  const _WebProfileEditButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.cardBorder,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const CustomText(
            text: 'Edit',
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 13,
            fontWeight: FontWeight.w400,
            textColor: AppColors.black,
          ),
        ),
      ),
    );
  }
}
