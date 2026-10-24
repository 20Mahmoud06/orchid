import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_fonts.dart';
import '../../../../../shared/widgets/custom_button.dart';
import '../../../../../shared/widgets/custom_text.dart';
import '../../../../../shared/widgets/skeleton_image.dart';

/// Desktop-first view bouquet page (>= 768px): photograph on one side with
/// the ingredient list and Edit Bouquet / Looks Good actions on the other.
class ViewBouquetWebView extends StatelessWidget {
  final String title;
  final String imagePath;
  final List<String> description;
  final bool showTwoButtons;
  final VoidCallback onEditBouquet;
  final VoidCallback onLooksGood;

  const ViewBouquetWebView({
    super.key,
    required this.title,
    required this.imagePath,
    required this.description,
    required this.showTwoButtons,
    required this.onEditBouquet,
    required this.onLooksGood,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(40, 36, 40, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomText(
                    text: title,
                    fontFamily: AppFonts.goudyOldStyle,
                    fontSize: 30,
                    fontWeight: FontWeight.w400,
                    textColor: AppColors.black,
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Rectangular bouquet photo.
                        Expanded(
                          flex: 5,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: SkeletonImage(
                              path: imagePath,
                              fit: BoxFit.cover,
                              errorWidget: const SkeletonFallbackBox(
                                color: AppColors.fieldPink,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 40),
                        // Details with the actions underneath.
                        Expanded(
                          flex: 6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (description.isNotEmpty)
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: description
                                              .map(
                                                (line) => Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        bottom: 6,
                                                      ),
                                                  child: CustomText(
                                                    text: line,
                                                    fontFamily:
                                                        AppFonts.goudyOldStyle,
                                                    fontSize: 22,
                                                    textColor:
                                                        AppColors.textPrimary,
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              if (showTwoButtons)
                                Row(
                                  children: [
                                    Expanded(
                                      child: CustomButton(
                                        label: 'Edit Bouquet',
                                        fontFamily: AppFonts.goudyOldStyle,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w400,
                                        textColor: AppColors.primary,
                                        backgroundColor: AppColors.background,
                                        height: 54,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: AppColors.incrementButton,
                                          width: 1,
                                        ),
                                        boxShadow: const [],
                                        onPressed: onEditBouquet,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(child: _looksGoodButton()),
                                  ],
                                )
                              else
                                SizedBox(width: 420, child: _looksGoodButton()),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _looksGoodButton() {
    return CustomButton(
      label: 'Looks Good',
      fontFamily: AppFonts.goudyOldStyle,
      fontSize: 20,
      fontWeight: FontWeight.w400,
      textColor: AppColors.primary,
      backgroundColor: AppColors.incrementButton,
      height: 54,
      borderRadius: BorderRadius.circular(14),
      boxShadow: const [],
      onPressed: onLooksGood,
    );
  }
}
