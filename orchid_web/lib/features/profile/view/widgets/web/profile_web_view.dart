import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_fonts.dart';
import 'package:ORCHID/features/auth/data/models/user_profile_model.dart';

import '../../../../../shared/widgets/custom_text.dart';
import 'web_profile_action_button.dart';
import 'web_profile_card.dart';

/// Desktop-first web presentation (>= 768px): the profile data card followed
/// by the Log Out / Delete Account actions, centered on the background. The
/// colors, copy and behaviour mirror the mobile screen — only the layout
/// differs.
class ProfileWebView extends StatelessWidget {
  final String displayName;
  final String displayEmail;
  final String? imageUrl;
  final UserProfileModel? profile;
  final VoidCallback onEdit;
  final VoidCallback onLogout;
  final VoidCallback onDeleteAccount;

  const ProfileWebView({
    super.key,
    required this.displayName,
    required this.displayEmail,
    required this.imageUrl,
    required this.profile,
    required this.onEdit,
    required this.onLogout,
    required this.onDeleteAccount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 36),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomText(
                    text: 'My Profile',
                    fontFamily: AppFonts.goudyOldStyle,
                    fontSize: 34,
                    fontWeight: FontWeight.w400,
                    textColor: AppColors.darkGreen,
                  ),
                  const SizedBox(height: 28),
                  WebProfileCard(
                    displayName: displayName,
                    displayEmail: displayEmail,
                    imageUrl: imageUrl,
                    profile: profile,
                    onEdit: onEdit,
                  ),
                  const SizedBox(height: 36),
                  WebProfileActionButton(
                    label: 'Log Out',
                    background: AppColors.textFieldPink,
                    textColor: AppColors.darkGreen,
                    onPressed: onLogout,
                  ),
                  const SizedBox(height: 14),
                  WebProfileActionButton(
                    label: 'Delete Account',
                    background: AppColors.textFieldDarkerPink,
                    textColor: AppColors.redText,
                    icon: const Icon(
                      Ionicons.trash,
                      size: 20,
                      color: AppColors.redText,
                    ),
                    onPressed: onDeleteAccount,
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
