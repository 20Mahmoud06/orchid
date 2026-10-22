import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/phone_formatter.dart';
import '../../../../core/validators/phone_validator.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../cubit/edit_profile_state.dart';
import 'edit_profile_avatar.dart';
import 'profile_field_section.dart';
import 'profile_form_error_text.dart';

/// Scrollable Edit Profile form content.
class EditProfileForm extends StatelessWidget {
  const EditProfileForm({
    super.key,
    required this.formKey,
    required this.state,
    required this.usernameController,
    required this.phoneController,
    required this.whatsappController,
    required this.addressController,
    required this.currentPasswordController,
    required this.newPasswordController,
    required this.profileImage,
    required this.existingImageUrl,
    required this.onBackPressed,
    required this.onPickImage,
    required this.onSave,
  });

  final GlobalKey<FormState> formKey;
  final EditProfileState state;
  final TextEditingController usernameController;
  final TextEditingController phoneController;
  final TextEditingController whatsappController;
  final TextEditingController addressController;
  final TextEditingController currentPasswordController;
  final TextEditingController newPasswordController;
  final XFile? profileImage;
  final String? existingImageUrl;
  final VoidCallback? onBackPressed;
  final VoidCallback onPickImage;
  final VoidCallback onSave;

  String? _validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'please enter your username';
    }
    return null;
  }

  String? _validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'please enter your delivery address';
    }
    return null;
  }

  /// WhatsApp is optional — an empty value is allowed, anything else must be
  /// a valid 11-digit Egyptian mobile number.
  String? _validateWhatsapp(String? value) {
    final clean = (value ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.isEmpty) return null;
    return PhoneValidator.validateWhatsAppNumber(clean);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomAppBar.orchid(
              title: 'Edit Profile',
              onBackPressed: onBackPressed,
            ),
            SizedBox(height: 20.h),

            // Profile Avatar Section
            EditProfileAvatar(
              profileImage: profileImage,
              existingImageUrl: existingImageUrl,
              onTap: onPickImage,
            ),
            SizedBox(height: 24.h),

            ProfileFieldSection(
              label: 'Username',
              child: CustomTextField(
                controller: usernameController,
                textColor: AppColors.textFieldText,
                containerColor: AppColors.background,
                fillColor: AppColors.background,
                boxShadow: const [],
                borderRadius: 20.r,
                validator: _validateUsername,
              ),
            ),

            ProfileFieldSection(
              label: 'Phone Number',
              child: CustomTextField(
                controller: phoneController,
                textColor: AppColors.textFieldText,
                containerColor: AppColors.background,
                fillColor: AppColors.background,
                boxShadow: const [],
                keyboardType: TextInputType.phone,
                borderRadius: 20.r,
                validator: (value) =>
                    PhoneValidator.validateEgyptianPhone(value),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                  PhoneInputFormatter(),
                ],
              ),
            ),

            ProfileFieldSection(
              label: 'Whatsapp Number',
              child: CustomTextField(
                controller: whatsappController,
                textColor: AppColors.textFieldText,
                containerColor: AppColors.background,
                fillColor: AppColors.background,
                boxShadow: const [],
                keyboardType: TextInputType.phone,
                borderRadius: 20.r,
                validator: _validateWhatsapp,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                  PhoneInputFormatter(),
                ],
              ),
            ),

            ProfileFieldSection(
              label: 'Delivery Address',
              child: CustomTextField(
                controller: addressController,
                textColor: AppColors.textFieldText,
                containerColor: AppColors.background,
                fillColor: AppColors.background,
                boxShadow: const [],
                borderRadius: 20.r,
                validator: _validateAddress,
              ),
            ),

            ProfileFieldSection(
              label: 'Edit Password',
              child: CustomTextField(
                controller: currentPasswordController,
                hint: 'enter your current password',
                textColor: AppColors.textFieldText,
                containerColor: AppColors.background,
                fillColor: AppColors.background,
                boxShadow: const [],
                isPassword: true,
                borderRadius: 20.r,
              ),
            ),

            CustomTextField(
              controller: newPasswordController,
              hint: 'enter your new password',
              textColor: AppColors.textFieldText,
              containerColor: AppColors.background,
              fillColor: AppColors.background,
              boxShadow: const [],
              isPassword: true,
              borderRadius: 20.r,
            ),

            if (state.currentPasswordError != null)
              ProfileFormErrorText(message: state.currentPasswordError!),
            if (state.newPasswordError != null)
              ProfileFormErrorText(message: state.newPasswordError!),
            if (state.generalError != null)
              ProfileFormErrorText(message: state.generalError!, topSpacing: 8),
            SizedBox(height: 28.h),

            // Save Changes Button Reusing CustomButton
            CustomButton(
              label: 'Save Changes',
              height: 50.h,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              backgroundColor: AppColors.textFieldDarkerPink,
              textColor: AppColors.darkGreen,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: const [],
              isLoading: state.isSaving,
              onPressed: state.isSaving ? null : onSave,
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}
