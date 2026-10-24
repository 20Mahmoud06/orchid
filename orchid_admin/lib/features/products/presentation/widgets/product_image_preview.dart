import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_text.dart';

class ProductImagePreview extends StatelessWidget {
  const ProductImagePreview({
    super.key,
    required this.pickedBytes,
    required this.pickedFileName,
    required this.existingImageUrl,
    required this.isCreating,
    required this.onRemove,
    required this.onChangeImage,
  });

  final Uint8List? pickedBytes;
  final String? pickedFileName;
  final String? existingImageUrl;
  final bool isCreating;
  final VoidCallback onRemove;
  final VoidCallback onChangeImage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
                color: AppColors.orchidSoft1,
              ),
              clipBehavior: Clip.antiAlias,
              child: pickedBytes != null
                  ? Image.memory(pickedBytes!, fit: BoxFit.cover)
                  : Image.network(
                      existingImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _fallbackIcon(),
                    ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: InkWell(
                onTap: onRemove,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 14,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 14,
              color: AppColors.primary,
            ),
            const SizedBox(width: 6),
            CustomText(
              text:
                  pickedFileName ??
                  (isCreating ? 'Image selected' : 'Current image'),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            InkWell(
              onTap: onChangeImage,
              child: const CustomText(
                text: 'Change image',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _fallbackIcon() {
    return Container(
      color: AppColors.orchidSoft1,
      alignment: Alignment.center,
      child: const Icon(
        Icons.local_florist_outlined,
        size: 36,
        color: AppColors.orchidStrong,
      ),
    );
  }
}
