import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../core/utils/phone_formatter.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import 'complete_profile_avatar.dart';
import 'complete_profile_field.dart';
import 'complete_profile_header.dart';
import 'profile_form_error_text.dart';

/// Mobile layout of the complete-profile screen (unchanged presentation).
class CompleteProfileMobileView extends StatelessWidget {
  final VoidCallback? onBackPressed;
  final VoidCallback onPickImage;
  final VoidCallback? onSubmit;
  final TextEditingController usernameController;
  final TextEditingController phoneController;
  final TextEditingController whatsappController;
  final TextEditingController addressController;
  final XFile? profileImage;
  final bool isLoading;
  final String? usernameError;
  final String? phoneError;
  final String? addressError;
  final String? generalError;

  const CompleteProfileMobileView({
    super.key,
    required this.onBackPressed,
    required this.onPickImage,
    required this.onSubmit,
    required this.usernameController,
    required this.phoneController,
    required this.whatsappController,
    required this.addressController,
    required this.profileImage,
    required this.isLoading,
    required this.usernameError,
    required this.phoneError,
    required this.addressError,
    required this.generalError,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomAppBar(
                title: 'Complete Your Account',
                onBackPressed: onBackPressed,
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
                profileImage: profileImage,
                onTap: onPickImage,
              ),
              SizedBox(height: 50.h),
              CompleteProfileField(
                controller: usernameController,
                hint: 'user name',
                prefixIcon: Icon(
                  Icons.person,
                  size: 22.r,
                  color: AppColors.iconColor,
                ),
                errorText: usernameError,
              ),
              SizedBox(height: 16.h),
              CompleteProfileField(
                controller: phoneController,
                hint: 'phone number',
                prefixIcon: Icon(
                  Icons.phone,
                  size: 22.r,
                  color: AppColors.iconColor,
                ),
                errorText: phoneError,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                  PhoneInputFormatter(),
                ],
              ),
              SizedBox(height: 16.h),
              CompleteProfileField(
                controller: whatsappController,
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
                controller: addressController,
                hint: 'delivery address',
                prefixIcon: Icon(
                  Icons.location_on,
                  size: 22.r,
                  color: AppColors.iconColor,
                ),
                errorText: addressError,
              ),
              if (generalError != null)
                ProfileFormErrorText(message: generalError!, topSpacing: 8),
              SizedBox(height: 28.h),
              CustomButton(
                label: 'Complete Account',
                isLoading: isLoading,
                onPressed: onSubmit,
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
