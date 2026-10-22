import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/phone_formatter.dart';
import '../../../auth/cubit/auth_cubit.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text.dart';
import '../../cubit/complete_profile_cubit.dart';
import '../../cubit/complete_profile_state.dart';
import '../widgets/complete_profile_avatar.dart';
import '../widgets/complete_profile_field.dart';
import '../widgets/complete_profile_header.dart';
import '../widgets/profile_form_error_text.dart';
import '../widgets/profile_snack.dart';

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
  late final CompleteProfileCubit _completeProfileCubit = CompleteProfileCubit(
    _auth,
  );

  XFile? _profileImage;

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _addressController.dispose();
    _completeProfileCubit.close();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    if (_completeProfileCubit.state.isLoading) return;

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
    _completeProfileCubit.submit(
      username: _usernameController.text.trim(),
      phone: _phoneController.text.trim(),
      whatsapp: _whatsappController.text.trim(),
      address: _addressController.text.trim(),
      profileImage: _profileImage,
    );
  }

  /// Blocks leaving the screen as long as it sits at the root of the navigator
  /// (which it always is after signup/login/splash) and offers a clean way out:
  /// confirm, sign out and return to login.
  Future<void> _leave() async {
    if (_completeProfileCubit.state.isLoading) return;
    final shouldLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CompleteProfileCubit, CompleteProfileState>(
      bloc: _completeProfileCubit,
      listener: (context, state) {
        if (state.isSuccess) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.mainNav,
            (route) => false,
          );
        }
      },
      builder: (context, state) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          _leave();
        },
        child: Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomAppBar(
                    title: 'Complete Your Account',
                    onBackPressed: state.isLoading ? null : _leave,
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
                    errorText: state.usernameError,
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
                    errorText: state.phoneError,
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
                    errorText: state.addressError,
                  ),
                  if (state.generalError != null)
                    ProfileFormErrorText(
                      message: state.generalError!,
                      topSpacing: 8,
                    ),
                  SizedBox(height: 28.h),
                  CustomButton(
                    label: 'Complete Account',
                    isLoading: state.isLoading,
                    onPressed: state.isLoading ? null : _validateAndSubmit,
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
