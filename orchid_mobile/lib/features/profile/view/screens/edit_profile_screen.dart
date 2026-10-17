import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/phone_formatter.dart';
import '../../../../core/validators/phone_validator.dart';
import '../../../auth/cubit/auth_cubit.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../widgets/edit_profile_avatar.dart';
import '../widgets/profile_field_section.dart';
import '../widgets/profile_form_error_text.dart';
import '../widgets/profile_snack.dart';

/// Edit Profile Screen matching exact Orchid Figma design specifications.
///
/// The form is pre-filled with the real profile data (no static placeholders),
/// the avatar shows the uploaded profile picture, and Save persists changes to
/// the `profiles` table (plus an optional password change) in Supabase.
class EditProfileScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;

  const EditProfileScreen({
    super.key,
    this.onBackPressed,
  });

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

  @override
  void initState() {
    super.initState();
    final profile = _auth.userProfile;
    _usernameController =
        TextEditingController(text: profile?.username ?? '');
    _phoneController =
        TextEditingController(text: formatEgyptianPhone(profile?.phone ?? ''));
    _whatsappController =
        TextEditingController(text: formatEgyptianPhone(profile?.whatsapp ?? ''));
    _addressController =
        TextEditingController(text: profile?.address ?? '');
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _existingImageUrl =
        _auth.getProfileImageUrl(profile?.profileImage);

    _initialUsername = (profile?.username ?? '').trim();
    _initialPhone =
        (profile?.phone ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    _initialWhatsapp =
        (profile?.whatsapp ?? '').replaceAll(RegExp(r'[^0-9]'), '');
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
    final whatsapp =
        _whatsappController.text.replaceAll(RegExp(r'[^0-9]'), '');
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
      child: Scaffold(
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
                    ProfileFormErrorText(
                      message: _generalError!,
                      topSpacing: 8,
                    ),
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
      ),
    );
  }
}
