import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_fonts.dart';
import '../../../../../core/utils/phone_formatter.dart';
import '../../../../auth/view/widgets/auth_web_ui.dart';
import 'web_profile_avatars.dart';
import '../../../../../shared/widgets/custom_text.dart';

/// Desktop-first "edit profile" page (>= 768px): a wide rectangular panel the
/// same width as the profile screen. Mirrors the mobile fields, labels and
/// validation; only the presentation differs.
class EditProfileWebView extends StatelessWidget {
  final XFile? profileImage;
  final String? existingImageUrl;
  final VoidCallback onPickImage;
  final TextEditingController usernameController;
  final TextEditingController phoneController;
  final TextEditingController whatsappController;
  final TextEditingController addressController;
  final TextEditingController currentPasswordController;
  final TextEditingController newPasswordController;
  final String? usernameError;
  final String? phoneError;
  final String? whatsappError;
  final String? addressError;
  final String? currentPasswordError;
  final String? newPasswordError;
  final String? generalError;
  final VoidCallback onClearUsernameError;
  final VoidCallback onClearPhoneError;
  final VoidCallback onClearWhatsappError;
  final VoidCallback onClearAddressError;
  final VoidCallback onClearCurrentPasswordError;
  final VoidCallback onClearNewPasswordError;
  final bool isSaving;
  final VoidCallback onSave;

  const EditProfileWebView({
    super.key,
    required this.profileImage,
    required this.existingImageUrl,
    required this.onPickImage,
    required this.usernameController,
    required this.phoneController,
    required this.whatsappController,
    required this.addressController,
    required this.currentPasswordController,
    required this.newPasswordController,
    required this.usernameError,
    required this.phoneError,
    required this.whatsappError,
    required this.addressError,
    required this.currentPasswordError,
    required this.newPasswordError,
    required this.generalError,
    required this.onClearUsernameError,
    required this.onClearPhoneError,
    required this.onClearWhatsappError,
    required this.onClearAddressError,
    required this.onClearCurrentPasswordError,
    required this.onClearNewPasswordError,
    required this.isSaving,
    required this.onSave,
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
                  const CustomText(
                    text: 'Edit Profile',
                    fontFamily: AppFonts.goudyOldStyle,
                    fontSize: 34,
                    fontWeight: FontWeight.w400,
                    textColor: AppColors.darkGreen,
                  ),
                  const SizedBox(height: 28),
                  _buildCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard() {
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: WebEditProfileAvatar(
              profileImage: profileImage,
              existingImageUrl: existingImageUrl,
              onTap: onPickImage,
            ),
          ),
          const SizedBox(height: 28),
          _WebFieldRow(
            children: [
              AuthTextField(
                controller: usernameController,
                label: 'Username',
                errorText: usernameError,
                onChanged: (_) => onClearUsernameError(),
              ),
              AuthTextField(
                controller: phoneController,
                label: 'Phone Number',
                keyboardType: TextInputType.phone,
                errorText: phoneError,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                  PhoneInputFormatter(),
                ],
                onChanged: (_) => onClearPhoneError(),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _WebFieldRow(
            children: [
              AuthTextField(
                controller: whatsappController,
                label: 'Whatsapp Number',
                keyboardType: TextInputType.phone,
                errorText: whatsappError,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                  PhoneInputFormatter(),
                ],
                onChanged: (_) => onClearWhatsappError(),
              ),
              AuthTextField(
                controller: addressController,
                label: 'Delivery Address',
                errorText: addressError,
                onChanged: (_) => onClearAddressError(),
              ),
            ],
          ),
          const SizedBox(height: 26),
          const _WebSectionLabel('Edit Password'),
          const SizedBox(height: 14),
          _WebFieldRow(
            children: [
              AuthTextField(
                controller: currentPasswordController,
                label: 'Current Password',
                hint: 'enter your current password',
                isPassword: true,
                errorText: currentPasswordError,
                onChanged: (_) => onClearCurrentPasswordError(),
              ),
              AuthTextField(
                controller: newPasswordController,
                label: 'New Password',
                hint: 'enter your new password',
                isPassword: true,
                errorText: newPasswordError,
                onChanged: (_) => onClearNewPasswordError(),
              ),
            ],
          ),
          if (generalError != null) ...[
            const SizedBox(height: 16),
            AuthErrorText(message: generalError!),
          ],
          const SizedBox(height: 26),
          AuthPrimaryButton(
            label: 'Save Changes',
            isLoading: isSaving,
            onPressed: isSaving ? null : onSave,
          ),
        ],
      ),
    );
  }
}

/// Small section label used inside the desktop edit-profile panel.
class _WebSectionLabel extends StatelessWidget {
  final String text;

  const _WebSectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return CustomText(
      text: text,
      fontFamily: AppFonts.goudyOldStyle,
      fontSize: 18,
      fontWeight: FontWeight.w400,
      textColor: AppColors.black,
    );
  }
}

/// Two equal-width fields side by side, stacking when the panel gets narrow.
class _WebFieldRow extends StatelessWidget {
  final List<Widget> children;

  const _WebFieldRow({required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 520) {
          final stacked = <Widget>[];
          for (var i = 0; i < children.length; i++) {
            if (i > 0) stacked.add(const SizedBox(height: 18));
            stacked.add(children[i]);
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: stacked,
          );
        }

        final row = <Widget>[];
        for (var i = 0; i < children.length; i++) {
          if (i > 0) row.add(const SizedBox(width: 18));
          row.add(Expanded(child: children[i]));
        }
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: row);
      },
    );
  }
}
