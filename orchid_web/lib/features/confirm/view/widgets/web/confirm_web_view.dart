import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_fonts.dart';
import '../../../../../shared/widgets/custom_text.dart';
import '../../../../../shared/widgets/skeleton_image.dart';
import 'web_confirm_widgets.dart';

/// Desktop-first confirmation page (>= 768px). Same colors, copy and behaviour
/// as the mobile screen — the home shortcut pinned top-right and the
/// confirmation split in two columns: the completed illustration on the left,
/// the message and order code on the right.
class ConfirmWebView extends StatelessWidget {
  final String username;
  final String orderCode;
  final VoidCallback onHomePressed;

  const ConfirmWebView({
    super.key,
    required this.username,
    required this.orderCode,
    required this.onHomePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(40, 36, 40, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  WebConfirmHeader(onHomePressed: onHomePressed),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 960),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SkeletonImage(
                                path: AppAssets.completed,
                                width: 300,
                                fit: BoxFit.contain,
                                placeholderSize: const Size(300, 300),
                                errorWidget: const SkeletonFallbackBox(),
                              ),
                              const SizedBox(width: 56),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const CustomText(
                                      text: 'ORDER CONFIRMED !',
                                      fontFamily: AppFonts.goudyOldStyle,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      textColor: AppColors.primary,
                                    ),
                                    const SizedBox(height: 16),
                                    CustomText(
                                      text: 'Thank you, $username !',
                                      fontFamily: AppFonts.goudyOldStyle,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      textColor: AppColors.black,
                                    ),
                                    const SizedBox(height: 8),
                                    CustomText(
                                      text:
                                          'your bouquet has been confirmed successfully',
                                      fontFamily: AppFonts.goudyOldStyle,
                                      fontSize: 16,
                                      textColor: AppColors.black.withValues(
                                        alpha: 0.7,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    WebConfirmOrderCodeCard(
                                      orderCode: orderCode,
                                    ),
                                    const SizedBox(height: 28),
                                    const CustomText(
                                      text:
                                          'You Will Receive a WhatsApp\nMessage When Your Order is on\nits way',
                                      fontFamily: AppFonts.goudyOldStyle,
                                      fontSize: 22,
                                      textColor: AppColors.primary,
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 20),
                                    const CustomText(
                                      text: 'Thank you for choosing ORCHID',
                                      fontFamily: AppFonts.goudyOldStyle,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      textColor: AppColors.thanksText,
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
}
