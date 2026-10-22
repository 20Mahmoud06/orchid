import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/phone_formatter.dart';
import '../../../auth/cubit/auth_cubit.dart';
import '../../cubit/edit_profile_cubit.dart';
import '../../cubit/edit_profile_state.dart';
import '../widgets/edit_profile_form.dart';
import '../widgets/profile_snack.dart';

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
  late final EditProfileCubit _editProfileCubit = EditProfileCubit(_auth);

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
    _editProfileCubit.close();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    if (_editProfileCubit.state.isSaving) return;
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
    _editProfileCubit.clearErrors();

    // Validate profile fields (username, phone, whatsapp, address).
    if (!_formKey.currentState!.validate()) return;

    // Validate the optional password change.
    if (!_editProfileCubit.validatePasswords(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
    )) {
      return;
    }

    // Nothing was edited — don't report a misleading success.
    if (!_hasChanges()) {
      showProfileSnack(context, 'nothing changed');
      return;
    }

    _editProfileCubit.save(
      username: _usernameController.text.trim(),
      phone: _phoneController.text.trim(),
      whatsapp: _whatsappController.text.trim(),
      address: _addressController.text.trim(),
      wantsPasswordChange: _newPasswordController.text.isNotEmpty,
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
      profileImage: _profileImage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EditProfileCubit, EditProfileState>(
      bloc: _editProfileCubit,
      listener: (context, state) {
        if (!state.isSuccess) return;
        showProfileSnack(context, 'profile updated successfully');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) Navigator.maybePop(context);
        });
      },
      builder: (context, state) => PopScope(
        canPop: !state.isSaving,
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: EditProfileForm(
              formKey: _formKey,
              state: state,
              usernameController: _usernameController,
              phoneController: _phoneController,
              whatsappController: _whatsappController,
              addressController: _addressController,
              currentPasswordController: _currentPasswordController,
              newPasswordController: _newPasswordController,
              profileImage: _profileImage,
              existingImageUrl: _existingImageUrl,
              onBackPressed: widget.onBackPressed,
              onPickImage: _pickProfileImage,
              onSave: _validateAndSave,
            ),
          ),
        ),
      ),
    );
  }
}
