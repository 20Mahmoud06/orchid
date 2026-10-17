import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../core/utils/phone_formatter.dart';
import '../../../../core/validators/phone_validator.dart';
import '../../../auth/cubit/auth_cubit.dart';
import '../../../auth/view/widgets/auth_web_ui.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../widgets/edit_profile_avatar.dart';
import '../widgets/profile_field_section.dart';
import '../widgets/profile_form_error_text.dart';
import '../widgets/profile_snack.dart';
import '../widgets/web/web_profile_avatars.dart';

/// Edit Profile Screen matching exact Orchid Figma design specifications.
///
/// The form is pre-filled with the real profile data (no static placeholders),
/// the avatar shows the uploaded profile picture, and Save persists changes to
/// the `profiles` table (plus an optional password change) in Supabase.
class EditProfileScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;

  const EditProfileScreen({super.key, this.onBackPressed});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = AuthCubit.instance;

  late final TextEditingController _usernameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _whatsappController;
  late final TextEditingController _addressController;
  late final TextEditingController _currentPasswordController;
  late final TextEditingController _newPasswordController;

  XFile? _profileImage;
  String? _existingImageUrl;

  // Snapshots of the values loaded from the profile, used to detect whether the
  // user actually changed anything before firing a save.
  late final String _initialUsername;
  late final String _initialPhone;
  late final String _initialWhatsapp;
  late final String _initialAddress;

  bool _isSaving = false;
  String? _currentPasswordError;
  String? _newPasswordError;
  String? _generalError;

  // Web-only inline field errors (the desktop form validates manually instead of
  // through the mobile [Form]/CustomTextField validators).
  String? _webUsernameError;
  String? _webPhoneError;
  String? _webWhatsappError;
  String? _webAddressError;

  @override
  void initState() {
    super.initState();
    final profile = _auth.userProfile;
    _usernameController = TextEditingController(text: profile?.username ?? '');
    _phoneController = TextEditingController(
      text: formatEgyptianPhone(profile?.phone ?? ''),
    );
    _whatsappController = TextEditingController(
      text: formatEgyptianPhone(profile?.whatsapp ?? ''),
    );
    _addressController = TextEditingController(text: profile?.address ?? '');
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _existingImageUrl = _auth.getProfileImageUrl(profile?.profileImage);

    _initialUsername = (profile?.username ?? '').trim();
    _initialPhone = (profile?.phone ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    _initialWhatsapp = (profile?.whatsapp ?? '').replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
    _initialAddress = (profile?.address ?? '').trim();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _addressController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    if (_isSaving) return;
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

  bool _validatePasswords() {
    final currentPass = _currentPasswordController.text;
    final newPass = _newPasswordController.text;

    if (newPass.isNotEmpty && currentPass.isEmpty) {
      setState(() {
        _currentPasswordError = 'please enter your current password';
      });
      return false;
    }
    if (currentPass.isNotEmpty && newPass.isEmpty) {
      setState(() {
        _newPasswordError = 'please enter your new password';
      });
      return false;
    }
    if (currentPass.isNotEmpty && newPass.isNotEmpty) {
      if (newPass.length < 6) {
        setState(() {
          _newPasswordError = 'password must be at least 6 characters';
        });
        return false;
      }
      if (newPass == currentPass) {
        setState(() {
          _newPasswordError =
              'your new password must be different from your current password';
        });
        return false;
      }
    }
    return true;
  }

  /// Returns true when the form differs from the loaded profile in any way
  /// (profile fields, a newly picked picture, or a requested password change).
  bool _hasChanges() {
    final username = _usernameController.text.trim();
    final phone = _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final whatsapp = _whatsappController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final address = _addressController.text.trim();

    return username != _initialUsername ||
        phone != _initialPhone ||
        whatsapp != _initialWhatsapp ||
        address != _initialAddress ||
        _profileImage != null ||
        _currentPasswordController.text.isNotEmpty ||
        _newPasswordController.text.isNotEmpty;
  }

  void _validateAndSave() {
    setState(() {
      _currentPasswordError = null;
      _newPasswordError = null;
      _generalError = null;
    });

    // Validate profile fields (username, phone, whatsapp, address).
    if (!_formKey.currentState!.validate()) return;

    // Validate the optional password change.
    if (!_validatePasswords()) return;

    // Nothing was edited — don't report a misleading success.
    if (!_hasChanges()) {
      showProfileSnack(context, 'nothing changed');
      return;
    }

    _performSave();
  }

  /// Desktop counterpart of [_validateAndSave]. It reuses the same validator
  /// functions as the mobile form but surfaces the messages as inline field
  /// errors, since the web fields are plain [AuthTextField]s.
  void _validateAndSaveWeb() {
    final usernameError = _validateUsername(_usernameController.text);
    final phoneError = PhoneValidator.validateEgyptianPhone(
      _phoneController.text,
    );
    final whatsappError = _validateWhatsapp(_whatsappController.text);
    final addressError = _validateAddress(_addressController.text);

    setState(() {
      _webUsernameError = usernameError;
      _webPhoneError = phoneError;
      _webWhatsappError = whatsappError;
      _webAddressError = addressError;
      _currentPasswordError = null;
      _newPasswordError = null;
      _generalError = null;
    });

    // Validate the optional password change (it surfaces its own inline errors).
    // Evaluated together with the profile fields so every problem is shown at
    // once instead of one at a time.
    final passwordsValid = _validatePasswords();

    if (usernameError != null ||
        phoneError != null ||
        whatsappError != null ||
        addressError != null ||
        !passwordsValid) {
      return;
    }

    // Nothing was edited — don't report a misleading success.
    if (!_hasChanges()) {
      showProfileSnack(context, 'nothing changed');
      return;
    }

    _performSave();
  }

  Future<void> _performSave() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    final wantsPasswordChange = _newPasswordController.text.isNotEmpty;
    final oldProfileImagePath = _auth.userProfile?.profileImage;

    String? profileImagePath;
    try {
      // Upload a newly picked profile picture first (optional).
      if (_profileImage != null) {
        final bytes = await _profileImage!.readAsBytes();
        profileImagePath = await _auth.uploadProfileImage(
          bytes: bytes,
          contentType: _contentTypeFor(_profileImage!),
        );
      }

      final result = await _auth.editProfile(
        username: _usernameController.text.trim(),
        phone: _phoneController.text.trim(),
        whatsapp: _whatsappController.text.trim(),
        address: _addressController.text.trim(),
        profileImagePath: profileImagePath,
      );

      if (result is EditProfileFailure) {
        // The save failed after the image was uploaded — clean up the orphan.
        if (profileImagePath != null) {
          await _auth.deleteProfileImage(profileImagePath);
        }
        if (!mounted) return;
        setState(() {
          _isSaving = false;
          _generalError = result.message;
        });
        return;
      }

      // The old picture was replaced — remove the orphaned file.
      if (profileImagePath != null &&
          oldProfileImagePath != null &&
          oldProfileImagePath != profileImagePath) {
        await _auth.deleteProfileImage(oldProfileImagePath);
      }

      // Password change is optional and runs only after the profile saved.
      if (wantsPasswordChange) {
        final passwordError = await _auth.changePassword(
          currentPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text,
        );
        if (passwordError != null) {
          if (!mounted) return;
          setState(() {
            _isSaving = false;
            _generalError =
                'your profile changes were saved, but we could not update '
                'your password: $passwordError';
          });
          return;
        }
      }

      if (!mounted) return;

      // Clear the saving flag first so the PopScope (canPop: !_isSaving) stops
      // blocking navigation, then rebuild and head back to the profile screen.
      setState(() {
        _isSaving = false;
      });
      showProfileSnack(context, 'profile updated successfully');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.maybePop(context);
      });
    } catch (error) {
      // An upload error (a thrown String) or an unexpected failure.
      if (profileImagePath != null) {
        await _auth.deleteProfileImage(profileImagePath);
      }
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _generalError = error is String
            ? error
            : 'failed to save your changes, please try again';
      });
    }
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
      canPop: !_isSaving,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Desktop-first web presentation: the same restrained, centered panel
          // used by the other profile/auth pages. Narrow viewports keep the
          // existing Orchid mobile layout.
          if (constraints.maxWidth >= 768) {
            return _buildWeb();
          }
          return _buildMobile();
        },
      ),
    );
  }

  /// Mobile layout (unchanged).
  Widget _buildMobile() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomAppBar.orchid(
                  title: 'Edit Profile',
                  onBackPressed: widget.onBackPressed,
                ),
                SizedBox(height: 20.h),

                // Profile Avatar Section
                EditProfileAvatar(
                  profileImage: _profileImage,
                  existingImageUrl: _existingImageUrl,
                  onTap: _pickProfileImage,
                ),
                SizedBox(height: 24.h),

                ProfileFieldSection(
                  label: 'Username',
                  child: CustomTextField(
                    controller: _usernameController,
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
                    controller: _phoneController,
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
                    controller: _whatsappController,
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
                    controller: _addressController,
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
                    controller: _currentPasswordController,
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
                  controller: _newPasswordController,
                  hint: 'enter your new password',
                  textColor: AppColors.textFieldText,
                  containerColor: AppColors.background,
                  fillColor: AppColors.background,
                  boxShadow: const [],
                  isPassword: true,
                  borderRadius: 20.r,
                ),

                if (_currentPasswordError != null)
                  ProfileFormErrorText(message: _currentPasswordError!),
                if (_newPasswordError != null)
                  ProfileFormErrorText(message: _newPasswordError!),
                if (_generalError != null)
                  ProfileFormErrorText(message: _generalError!, topSpacing: 8),
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
                  isLoading: _isSaving,
                  onPressed: _isSaving ? null : _validateAndSave,
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Desktop-first "edit profile" page (>= 768px): a wide rectangular panel the
  /// same width as the profile screen. Mirrors the mobile fields, labels and
  /// validation; only the presentation differs.
  Widget _buildWeb() {
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
                  const Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontFamily: AppFonts.goudyOldStyle,
                      fontSize: 34,
                      fontWeight: FontWeight.w400,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 28),
                  _buildWebCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWebCard() {
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
              profileImage: _profileImage,
              existingImageUrl: _existingImageUrl,
              onTap: _pickProfileImage,
            ),
          ),
          const SizedBox(height: 28),
          _WebFieldRow(
            children: [
              AuthTextField(
                controller: _usernameController,
                label: 'Username',
                errorText: _webUsernameError,
                onChanged: (_) {
                  if (_webUsernameError != null) {
                    setState(() => _webUsernameError = null);
                  }
                },
              ),
              AuthTextField(
                controller: _phoneController,
                label: 'Phone Number',
                keyboardType: TextInputType.phone,
                errorText: _webPhoneError,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                  PhoneInputFormatter(),
                ],
                onChanged: (_) {
                  if (_webPhoneError != null) {
                    setState(() => _webPhoneError = null);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 18),
          _WebFieldRow(
            children: [
              AuthTextField(
                controller: _whatsappController,
                label: 'Whatsapp Number',
                keyboardType: TextInputType.phone,
                errorText: _webWhatsappError,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                  PhoneInputFormatter(),
                ],
                onChanged: (_) {
                  if (_webWhatsappError != null) {
                    setState(() => _webWhatsappError = null);
                  }
                },
              ),
              AuthTextField(
                controller: _addressController,
                label: 'Delivery Address',
                errorText: _webAddressError,
                onChanged: (_) {
                  if (_webAddressError != null) {
                    setState(() => _webAddressError = null);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 26),
          const _WebSectionLabel('Edit Password'),
          const SizedBox(height: 14),
          _WebFieldRow(
            children: [
              AuthTextField(
                controller: _currentPasswordController,
                label: 'Current Password',
                hint: 'enter your current password',
                isPassword: true,
                errorText: _currentPasswordError,
                onChanged: (_) {
                  if (_currentPasswordError != null || _generalError != null) {
                    setState(() {
                      _currentPasswordError = null;
                      _generalError = null;
                    });
                  }
                },
              ),
              AuthTextField(
                controller: _newPasswordController,
                label: 'New Password',
                hint: 'enter your new password',
                isPassword: true,
                errorText: _newPasswordError,
                onChanged: (_) {
                  if (_newPasswordError != null || _generalError != null) {
                    setState(() {
                      _newPasswordError = null;
                      _generalError = null;
                    });
                  }
                },
              ),
            ],
          ),
          if (_generalError != null) ...[
            const SizedBox(height: 16),
            AuthErrorText(message: _generalError!),
          ],
          const SizedBox(height: 26),
          AuthPrimaryButton(
            label: 'Save Changes',
            isLoading: _isSaving,
            onPressed: _isSaving ? null : _validateAndSaveWeb,
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
    return Text(
      text,
      style: const TextStyle(
        fontFamily: AppFonts.goudyOldStyle,
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: AppColors.black,
      ),
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
