import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../../core/utils/phone_formatter.dart';
import '../../../../auth/view/widgets/auth_web_ui.dart';
import 'web_profile_avatars.dart';

/// Professional website "complete profile" panel (>= 768px). Mirrors the
/// mobile fields and validation; only the presentation differs.
class WebCompleteProfileView extends StatelessWidget {
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

  const WebCompleteProfileView({
    super.key,
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
    return AuthWebScaffold(
      card: AuthCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: WebCompleteProfileAvatar(
                profileImage: profileImage,
                onTap: onPickImage,
              ),
            ),
            const SizedBox(height: 26),
            const AuthHeading(
              title: 'Complete Your Account',
              subtitle: 'add your details to personalize your experience',
            ),
            const SizedBox(height: 28),
            AuthTextField(
              controller: usernameController,
              label: 'User name',
              hint: 'user name',
              prefixIcon: const Icon(Icons.person, size: 20),
              errorText: usernameError,
            ),
            const SizedBox(height: 18),
            AuthTextField(
              controller: phoneController,
              label: 'Phone number',
              hint: 'phone number',
              keyboardType: TextInputType.phone,
              prefixIcon: const Icon(Icons.phone, size: 20),
              errorText: phoneError,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
                PhoneInputFormatter(),
              ],
            ),
            const SizedBox(height: 18),
            AuthTextField(
              controller: whatsappController,
              label: 'WhatsApp number',
              hint: 'whatsapp number (optional)',
              keyboardType: TextInputType.phone,
              prefixIcon: const Icon(Ionicons.logo_whatsapp, size: 20),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
                PhoneInputFormatter(),
              ],
            ),
            const SizedBox(height: 18),
            AuthTextField(
              controller: addressController,
              label: 'Delivery address',
              hint: 'delivery address',
              prefixIcon: const Icon(Icons.location_on, size: 20),
              errorText: addressError,
            ),
            if (generalError != null) ...[
              const SizedBox(height: 16),
              AuthErrorText(message: generalError!),
            ],
            const SizedBox(height: 26),
            AuthPrimaryButton(
              label: 'Complete Account',
              isLoading: isLoading,
              onPressed: onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}
