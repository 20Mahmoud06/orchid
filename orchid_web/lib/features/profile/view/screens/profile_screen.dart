import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ionicons/ionicons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../core/router/app_routes.dart';
import '../../../auth/cubit/auth_cubit.dart';
import '../../../auth/cubit/auth_state.dart';
import '../../../auth/data/models/user_profile_model.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text.dart';
import '../widgets/profile_dialogs.dart';
import '../widgets/profile_header_card.dart';
import '../widgets/web/web_profile_widgets.dart';

/// Profile Screen matching exact Orchid Figma design specifications.
///
/// Displays the real profile data from Supabase (username, email, phone,
/// whatsapp, address, profile picture) and rebuilds reactively whenever the
/// auth state/profile changes (e.g. after editing the profile).
class ProfileScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;
  final VoidCallback? onNavigateToEditProfile;

  const ProfileScreen({
    super.key,
    this.onBackPressed,
    this.onNavigateToEditProfile,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Pull fresh profile data from Supabase when the screen is first shown so
    // nothing is ever stale (e.g. after a silent session restore).
    AuthCubit.instance.refreshProfile();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthFlowState>(
      bloc: AuthCubit.instance,
      builder: (context, state) => _buildScreen(context),
    );
  }

  Widget _buildScreen(BuildContext context) {
    final auth = AuthCubit.instance;
    final profile = auth.userProfile;
    final displayName =
        (profile?.username?.isNotEmpty ?? false) ? profile!.username! : 'User';
    final displayEmail =
        Supabase.instance.client.auth.currentUser?.email ?? '';
    final imageUrl = auth.getProfileImageUrl(profile?.profileImage);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Desktop-first web presentation (>= 768px): a wide, centered profile
        // dashboard. Narrow viewports keep the untouched Orchid mobile layout.
        if (constraints.maxWidth >= 768) {
          return _buildWeb(
            context,
            displayName: displayName,
            displayEmail: displayEmail,
            imageUrl: imageUrl,
            profile: profile,
          );
        }
        return _buildMobile(
          context,
          displayName: displayName,
          displayEmail: displayEmail,
          imageUrl: imageUrl,
          profile: profile,
        );
      },
    );
  }

  /// Mobile layout (unchanged).
  Widget _buildMobile(
    BuildContext context, {
    required String displayName,
    required String displayEmail,
    required String? imageUrl,
    required UserProfileModel? profile,
  }) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==========================================
              // Top Header
              // ==========================================
              Row(
                children: [
                  Expanded(
                    child: Center(
                      child: CustomText(
                        text: 'My Profile',
                        fontFamily: AppFonts.goudyOldStyle,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w400,
                        textColor: AppColors.black,
                      ),
                    ),
                  ),
                  SizedBox(width: 20.w),
                ],
              ),

              SizedBox(height: 24.h),

              // ==========================================
              // Profile Card
              // ==========================================
              ProfileHeaderCard(
                displayName: displayName,
                displayEmail: displayEmail,
                imageUrl: imageUrl,
                profile: profile,
                onEdit: _openEditProfile,
              ),

              SizedBox(height: 40.h),

              // ==========================================
              // Log Out
              // ==========================================
              CustomButton(
                label: 'Log Out',
                height: 48.h,
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                backgroundColor: AppColors.textFieldPink,
                textColor: AppColors.darkGreen,
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: const [],
                onPressed: () => showLogoutDialog(context),
              ),

              SizedBox(height: 12.h),

              // ==========================================
              // Delete Account
              // ==========================================
              CustomButton(
                label: 'Delete Account',
                height: 48.h,
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                backgroundColor: AppColors.textFieldDarkerPink,
                textColor: AppColors.redText,
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: const [],
                icon: Icon(
                  Ionicons.trash,
                  size: 20.r,
                  color: AppColors.redText,
                ),
                onPressed: () => showDeleteAccountDialog(context),
              ),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  /// Desktop-first web presentation (>= 768px): the profile data card followed
  /// by the Log Out / Delete Account actions, centered on the background. The
  /// colors, copy and behaviour mirror the mobile screen — only the layout
  /// differs.
  Widget _buildWeb(
    BuildContext context, {
    required String displayName,
    required String displayEmail,
    required String? imageUrl,
    required UserProfileModel? profile,
  }) {
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
                    onEdit: _openEditProfile,
                  ),
                  const SizedBox(height: 36),
                  WebProfileActionButton(
                    label: 'Log Out',
                    background: AppColors.textFieldPink,
                    textColor: AppColors.darkGreen,
                    onPressed: () => showLogoutDialog(context),
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
                    onPressed: () => showDeleteAccountDialog(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openEditProfile() {
    if (widget.onNavigateToEditProfile != null) {
      widget.onNavigateToEditProfile!();
      return;
    }
    Navigator.pushNamed(context, AppRoutes.editProfile).then((_) {
      // Refresh on return so the screen always shows the saved row, even if a
      // fetch glitch left the controller's copy stale.
      if (mounted) AuthCubit.instance.refreshProfile();
    });
  }
}
