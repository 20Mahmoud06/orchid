import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ionicons/ionicons.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/phone_formatter.dart';
import '../../../../core/utils/viewport.dart';
import '../../../../core/validators/phone_validator.dart';
import '../../../auth/cubit/auth_cubit.dart';
import '../../../auth/view/widgets/auth_web_ui.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text.dart';
import '../widgets/complete_profile_avatar.dart';
import '../widgets/complete_profile_field.dart';
import '../widgets/complete_profile_header.dart';
import '../widgets/profile_form_error_text.dart';
import '../widgets/profile_snack.dart';
import '../widgets/web/web_profile_avatars.dart';

/// Complete Your Profile Screen matching Orchid design specifications with PNG icons.
class CompleteProfileScreen extends StatefulWidget {
  /// Whether this flow started from a fresh sign-up (vs. logging in with an
  /// existing incomplete account). When true, account creation first shows a
  /// "created successfully" dialog before sending the user to login.
  final bool fromSignUp;

  const CompleteProfileScreen({super.key, this.fromSignUp = false});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

/// Optional route arguments for [CompleteProfileScreen].
class CompleteProfileArgs {
  final bool fromSignUp;

  const CompleteProfileArgs({this.fromSignUp = false});
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final _auth = AuthCubit.instance;

  XFile? _profileImage;
  bool _isLoading = false;
  String? _usernameError;
  String? _phoneError;
  String? _addressError;
  String? _generalError;

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    if (_isLoading) return;

    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
      );
      if (picked == null || !mounted) return;
      setState(() => _profileImage = picked);
    } catch (_) {
      if (!mounted) return;
      showProfileSnack(
        context,
        'unable to pick a profile picture, please try again',
        isError: true,
      );
    }
  }

  void _validateAndSubmit() {
    setState(() {
      _usernameError = null;
      _phoneError = null;
      _addressError = null;
      _generalError = null;
    });

    final username = _usernameController.text.trim();
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();

    // Validate username.
    if (username.isEmpty) {
      setState(() => _usernameError = 'please enter your username');
      return;
    }

    // Validate phone.
    final phoneErr = PhoneValidator.validateEgyptianPhone(phone);
    if (phoneErr != null) {
      setState(() => _phoneError = phoneErr);
      return;
    }

    // Validate address.
    if (address.isEmpty) {
      setState(() => _addressError = 'please enter your delivery address');
      return;
    }

    _performCompleteProfile(
      username: username,
      phone: phone,
      whatsapp: _whatsappController.text.trim(),
      address: address,
    );
  }

  Future<void> _performCompleteProfile({
    required String username,
    required String phone,
    String? whatsapp,
    required String address,
  }) async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    _generalError = null;

    String? profileImagePath;
    try {
      // Upload the profile picture first (optional).
      if (_profileImage != null) {
        final bytes = await _profileImage!.readAsBytes();
        profileImagePath = await _auth.uploadProfileImage(
          bytes: bytes,
          contentType: _contentTypeFor(_profileImage!),
        );
      }

      final result = await _auth.completeProfile(
        username: username,
        phone: phone,
        whatsapp: whatsapp,
        address: address,
        profileImagePath: profileImagePath,
      );

      if (!mounted) return;

      switch (result) {
        case CompleteProfileSuccess():
          await _handleProfileSuccess();
          break;
        case CompleteProfileFailure():
          // The save failed after the image was uploaded — clean up the orphan.
          if (profileImagePath != null) {
            await _auth.deleteProfileImage(profileImagePath);
          }
          if (!mounted) return;
          setState(() => _generalError = result.message);
          break;
      }
    } catch (error) {
      // Clean up the orphaned upload before surfacing the error.
      if (profileImagePath != null) {
        await _auth.deleteProfileImage(profileImagePath);
      }
      if (!mounted) return;
      setState(() {
        _generalError = error is String
            ? error
            : 'failed to save your profile, please try again';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Handles what happens after the profile row is saved successfully.
  /// Both a fresh sign-up and an existing registered user land on the main
  /// navigation afterwards. The user is NEVER forced back to the login screen
  /// or signed out here: they just completed their profile and the session is
  /// still valid, so dropping them into a re-login is both redundant and
  /// confusing.
  Future<void> _handleProfileSuccess() async {
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.mainNav,
      (route) => false,
    );
  }

  /// Blocks leaving the screen as long as it sits at the root of the navigator
  /// (which it always is after signup/login/splash) and offers a clean way out:
  /// confirm, sign out and return to login.
  Future<void> _leave() async {
    if (_isLoading) return;
    final shouldLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(
          // Fixed logical radius on desktop web (ScreenUtil would scale .r
          // with the pinned phone width); the mobile layout keeps 20.r.
          borderRadius: BorderRadius.circular(
            isWideViewport(dialogContext) ? 20 : 20.r,
          ),
        ),
        title: const CustomText(
          text: 'Leave?',
          fontFamily: AppFonts.inriaSerif,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          textColor: AppColors.darkGreen,
        ),
        content: const CustomText(
          text:
              "your profile isn't complete yet.\n"
              'logging out now means you will need to complete it '
              'after logging back in.',
          fontFamily: AppFonts.inriaSerif,
          fontSize: 14,
          textColor: AppColors.textPrimary,
          height: 1.3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const CustomText(
              text: 'stay',
              fontFamily: AppFonts.inriaSerif,
              fontSize: 14,
              textColor: AppColors.darkGreen,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const CustomText(
              text: 'log out',
              fontFamily: AppFonts.inriaSerif,
              fontSize: 14,
              textColor: AppColors.error,
            ),
          ),
        ],
      ),
    );
    if (shouldLogout != true || !mounted) return;

    await _auth.logout();
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }

  String _contentTypeFor(XFile file) {
    final name = file.name.toLowerCase();
    if (name.endsWith('.png')) return 'image/png';
    if (name.endsWith('.webp')) return 'image/webp';
    if (name.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _leave();
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Desktop-first web presentation: the same restrained, centered panel
          // used by the other auth pages. Narrow viewports keep the existing
          // Orchid mobile layout.
          if (constraints.maxWidth >= 768) {
            return AuthWebScaffold(card: _buildWebCard());
          }

          return Scaffold(
            body: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomAppBar(
                      title: 'Complete Your Account',
                      onBackPressed: _isLoading ? null : _leave,
                      titleFontFamily: AppFonts.inriaSerif,
                      titleFontSize: 29.sp,
                      titleColor: AppColors.darkGreen,
                      titleFontWeight: FontWeight.w400,
                      padding: EdgeInsets.zero,
                      centerWidget: const CompleteProfileHeader(),
                    ),
                    SizedBox(height: 50.h),
                    // Circular Profile Image Placeholder with Camera Icon
                    CompleteProfileAvatar(
                      profileImage: _profileImage,
                      onTap: _pickProfileImage,
                    ),
                    SizedBox(height: 50.h),
                    CompleteProfileField(
                      controller: _usernameController,
                      hint: 'user name',
                      prefixIcon: Icon(
                        Icons.person,
                        size: 22.r,
                        color: AppColors.iconColor,
                      ),
                      errorText: _usernameError,
                    ),
                    SizedBox(height: 16.h),
                    CompleteProfileField(
                      controller: _phoneController,
                      hint: 'phone number',
                      prefixIcon: Icon(
                        Icons.phone,
                        size: 22.r,
                        color: AppColors.iconColor,
                      ),
                      errorText: _phoneError,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(11),
                        PhoneInputFormatter(),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    CompleteProfileField(
                      controller: _whatsappController,
                      hint: 'whatsapp number (optional)',
                      prefixIcon: Image.asset(
                        AppAssets.whatsappIcon,
                        width: 22.r,
                        height: 22.r,
                      ),
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(11),
                        PhoneInputFormatter(),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    CompleteProfileField(
                      controller: _addressController,
                      hint: 'delivery address',
                      prefixIcon: Icon(
                        Icons.location_on,
                        size: 22.r,
                        color: AppColors.iconColor,
                      ),
                      errorText: _addressError,
                    ),
                    if (_generalError != null)
                      ProfileFormErrorText(
                        message: _generalError!,
                        topSpacing: 8,
                      ),
                    SizedBox(height: 28.h),
                    CustomButton(
                      label: 'Complete Account',
                      isLoading: _isLoading,
                      onPressed: _isLoading ? null : _validateAndSubmit,
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Professional website "complete profile" panel (>= 768px). Mirrors the
  /// mobile fields and validation; only the presentation differs.
  Widget _buildWebCard() {
    return AuthCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: WebCompleteProfileAvatar(
              profileImage: _profileImage,
              onTap: _pickProfileImage,
            ),
          ),
          const SizedBox(height: 26),
          const AuthHeading(
            title: 'Complete Your Account',
            subtitle: 'add your details to personalize your experience',
          ),
          const SizedBox(height: 28),
          AuthTextField(
            controller: _usernameController,
            label: 'User name',
            hint: 'user name',
            prefixIcon: const Icon(Icons.person, size: 20),
            errorText: _usernameError,
          ),
          const SizedBox(height: 18),
          AuthTextField(
            controller: _phoneController,
            label: 'Phone number',
            hint: 'phone number',
            keyboardType: TextInputType.phone,
            prefixIcon: const Icon(Icons.phone, size: 20),
            errorText: _phoneError,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
              PhoneInputFormatter(),
            ],
          ),
          const SizedBox(height: 18),
          AuthTextField(
            controller: _whatsappController,
            label: 'WhatsApp number',
            hint: 'whatsapp number (optional)',
            keyboardType: TextInputType.phone,
            prefixIcon: const Icon(
                                Ionicons.logo_whatsapp,
                  size: 20,
              ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
              PhoneInputFormatter(),
            ],
          ),
          const SizedBox(height: 18),
          AuthTextField(
            controller: _addressController,
            label: 'Delivery address',
            hint: 'delivery address',
            prefixIcon: const Icon(Icons.location_on, size: 20),
            errorText: _addressError,
          ),
          if (_generalError != null) ...[
            const SizedBox(height: 16),
            AuthErrorText(message: _generalError!),
          ],
          const SizedBox(height: 26),
          AuthPrimaryButton(
            label: 'Complete Account',
            isLoading: _isLoading,
            onPressed: _isLoading ? null : _validateAndSubmit,
          ),
        ],
      ),
    );
  }
}
