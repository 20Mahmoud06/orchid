import 'package:image_picker/image_picker.dart';

/// Picks profile pictures for the profile screens.
class ProfileImagePicker {
  static Future<XFile?> pick() {
    return ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
      maxHeight: 1200,
    );
  }
}
