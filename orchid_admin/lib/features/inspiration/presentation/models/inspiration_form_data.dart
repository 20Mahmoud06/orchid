import 'dart:typed_data';

import '../../domain/models/inspiration_model.dart';

class InspirationFormData {
  const InspirationFormData({
    required this.displayName,
    required this.ingredients,
    required this.imageBytes,
    required this.imageName,
    this.avatarBytes,
    this.avatarName,
  });

  final String? displayName;
  final List<InspirationIngredient> ingredients;
  final Uint8List imageBytes;
  final String imageName;
  final Uint8List? avatarBytes;
  final String? avatarName;
}
