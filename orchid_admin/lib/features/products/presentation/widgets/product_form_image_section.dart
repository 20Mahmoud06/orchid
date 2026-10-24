import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_text.dart';
import 'product_form_section_title.dart';
import 'product_image_uploader.dart';

class ProductFormImageSection extends StatelessWidget {
  const ProductFormImageSection({
    super.key,
    required this.pickedBytes,
    required this.pickedFileName,
    required this.existingImageUrl,
    required this.isCreating,
    required this.onImagePicked,
    required this.onImageRemoved,
  });

  final Uint8List? pickedBytes;
  final String? pickedFileName;
  final String? existingImageUrl;
  final bool isCreating;
  final void Function(Uint8List bytes, String fileName) onImagePicked;
  final VoidCallback onImageRemoved;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ProductFormSectionTitle(
          title: 'Product Image',
          icon: Icons.image_outlined,
        ),
        const SizedBox(height: 20),
        ProductImageUploader(
          pickedBytes: pickedBytes,
          pickedFileName: pickedFileName,
          existingImageUrl: existingImageUrl,
          isCreating: isCreating,
          onImagePicked: onImagePicked,
          onImageRemoved: onImageRemoved,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(
              Icons.cloud_upload_outlined,
              size: 14,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: CustomText(
                text:
                    'Images are stored in Supabase Storage and displayed directly '
                    'in the Orchid mobile app.',
                style: AppTextStyles.caption,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
