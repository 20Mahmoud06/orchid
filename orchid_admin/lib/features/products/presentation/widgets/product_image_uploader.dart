import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'product_image_dropzone.dart';
import 'product_image_preview.dart';

class ProductImageUploader extends StatelessWidget {
  const ProductImageUploader({
    super.key,
    this.pickedBytes,
    this.pickedFileName,
    this.existingImageUrl,
    this.isCreating = false,
    this.dropzoneLabel = 'Click to select a product image or ',
    required this.onImagePicked,
    required this.onImageRemoved,
  });

  final Uint8List? pickedBytes;
  final String? pickedFileName;
  final String? existingImageUrl;
  final bool isCreating;
  final String dropzoneLabel;
  final void Function(Uint8List bytes, String fileName) onImagePicked;
  final VoidCallback onImageRemoved;

  bool get _hasImage =>
      pickedBytes != null || (existingImageUrl?.isNotEmpty ?? false);

  Future<void> _pickImage() async {
    try {
      final results = await FilePicker.pickFiles(type: FileType.image);
      if (results.isEmpty) return;
      final file = results.first;
      final bytes = await file.readAsBytes();
      onImagePicked(bytes, file.name);
    } catch (_) {
      // User cancelled or the file could not be read; keep the current image.
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasImage) {
      return ProductImagePreview(
        pickedBytes: pickedBytes,
        pickedFileName: pickedFileName,
        existingImageUrl: existingImageUrl,
        isCreating: isCreating,
        onRemove: onImageRemoved,
        onChangeImage: _pickImage,
      );
    }

    return ProductImageDropzone(onTap: _pickImage, label: dropzoneLabel);
  }
}
