import 'package:image_picker/image_picker.dart';

/// Resolves the content type Supabase Storage should store for a picked
/// profile picture, falling back to JPEG for unknown extensions.
String contentTypeForImageFile(XFile file) {
  final name = file.name.toLowerCase();
  if (name.endsWith('.png')) return 'image/png';
  if (name.endsWith('.webp')) return 'image/webp';
  if (name.endsWith('.gif')) return 'image/gif';
  return 'image/jpeg';
}
