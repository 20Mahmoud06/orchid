import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/utils/phone_formatter.dart';
import '../../../../core/validators/phone_validator.dart';
import '../../../auth/cubit/auth_cubit.dart';
import '../../utils/edit_profile_save_operation.dart';
import '../../utils/edit_profile_validators.dart';
import '../../utils/profile_image_picker.dart';
import '../widgets/edit_profile_mobile_view.dart';
import '../widgets/profile_snack.dart';
import '../widgets/web/web_edit_profile_view.dart';

/// Edit Profile Screen matching exact Orchid Figma design specifications.
///
/// The form is pre-filled with the real profile data (no static placeholders),
/// the avatar shows the uploaded profile picture, and Save persists changes to
/// the `profiles` table (plus an optional password change) in Supabase.
///
/// The mobile and desktop layouts live in separate widget files; this screen
/// owns the form state, validation and save flow.
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
      final picked = await ProfileImagePicker.pick();
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

  String? _validateUsername(String? value) =>
      EditProfileValidators.validateUsername(value);

  String? _validateAddress(String? value) =>
      EditProfileValidators.validateAddress(value);

  /// WhatsApp is optional — an empty value is allowed, anything else must be
  /// a valid 11-digit Egyptian mobile number.
  String? _validateWhatsapp(String? value) =>
      EditProfileValidators.validateWhatsapp(value);

  bool _validatePasswords() {
    final result = EditProfileValidators.validatePasswords(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
    );
    if (!result.isValid) {
      setState(() {
        _currentPasswordError = result.currentPasswordError;
        _newPasswordError = result.newPasswordError;
      });
      return false;
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

    final outcome = await EditProfileSaveOperation(
      auth: _auth,
      profileImage: _profileImage,
      usernameController: _usernameController,
      phoneController: _phoneController,
      whatsappController: _whatsappController,
      addressController: _addressController,
      currentPasswordController: _currentPasswordController,
      newPasswordController: _newPasswordController,
    ).run();

    if (!mounted) return;

    switch (outcome) {
      case EditProfileSaveSuccess():
        // Clear the saving flag first so the PopScope (canPop: !_isSaving)
        // stops blocking navigation, then rebuild and head back to the profile
        // screen.
        setState(() {
          _isSaving = false;
        });
        showProfileSnack(context, 'profile updated successfully');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) Navigator.maybePop(context);
        });
      case EditProfileSaveFailure(:final message):
        setState(() {
          _isSaving = false;
          _generalError = message;
        });
    }
  }

  void _clearUsernameError() {
    if (_webUsernameError == null) return;
    setState(() => _webUsernameError = null);
  }

  void _clearPhoneError() {
    if (_webPhoneError == null) return;
    setState(() => _webPhoneError = null);
  }

  void _clearWhatsappError() {
    if (_webWhatsappError == null) return;
    setState(() => _webWhatsappError = null);
  }

  void _clearAddressError() {
    if (_webAddressError == null) return;
    setState(() => _webAddressError = null);
  }

  void _clearCurrentPasswordError() {
    if (_currentPasswordError == null && _generalError == null) return;
    setState(() {
      _currentPasswordError = null;
      _generalError = null;
    });
  }

  void _clearNewPasswordError() {
    if (_newPasswordError == null && _generalError == null) return;
    setState(() {
      _newPasswordError = null;
      _generalError = null;
    });
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
            return EditProfileWebView(
              profileImage: _profileImage,
              existingImageUrl: _existingImageUrl,
              onPickImage: _pickProfileImage,
              usernameController: _usernameController,
              phoneController: _phoneController,
              whatsappController: _whatsappController,
              addressController: _addressController,
              currentPasswordController: _currentPasswordController,
              newPasswordController: _newPasswordController,
              usernameError: _webUsernameError,
              phoneError: _webPhoneError,
              whatsappError: _webWhatsappError,
              addressError: _webAddressError,
              currentPasswordError: _currentPasswordError,
              newPasswordError: _newPasswordError,
              generalError: _generalError,
              onClearUsernameError: _clearUsernameError,
              onClearPhoneError: _clearPhoneError,
              onClearWhatsappError: _clearWhatsappError,
              onClearAddressError: _clearAddressError,
              onClearCurrentPasswordError: _clearCurrentPasswordError,
              onClearNewPasswordError: _clearNewPasswordError,
              isSaving: _isSaving,
              onSave: _validateAndSaveWeb,
            );
          }
          return EditProfileMobileView(
            formKey: _formKey,
            usernameController: _usernameController,
            phoneController: _phoneController,
            whatsappController: _whatsappController,
            addressController: _addressController,
            currentPasswordController: _currentPasswordController,
            newPasswordController: _newPasswordController,
            profileImage: _profileImage,
            existingImageUrl: _existingImageUrl,
            onPickImage: _pickProfileImage,
            onBackPressed: widget.onBackPressed,
            usernameValidator: _validateUsername,
            whatsappValidator: _validateWhatsapp,
            addressValidator: _validateAddress,
            currentPasswordError: _currentPasswordError,
            newPasswordError: _newPasswordError,
            generalError: _generalError,
            isSaving: _isSaving,
            onSave: _validateAndSave,
          );
        },
      ),
    );
  }
}
