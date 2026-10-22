import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_fonts.dart';
import '../../../../../core/utils/phone_formatter.dart';
import '../../../../../core/validators/phone_validator.dart';
import '../../../../../shared/widgets/custom_button.dart';
import '../../../../../shared/widgets/custom_text.dart';
import 'web_delivery_widgets.dart';

/// Desktop-first delivery details page (>= 768px). Same colors, copy and
/// behaviour as the mobile screen — a two-column layout like "my cart": the
/// address form on the left with the estimated delivery card and the continue
/// button in the summary sidebar.
class DeliveryDetailsWebView extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController fullNameController;
  final TextEditingController phoneController;
  final TextEditingController whatsappController;
  final TextEditingController locationController;
  final TextEditingController notesController;
  final VoidCallback? onBackPressed;
  final VoidCallback onContinue;

  const DeliveryDetailsWebView({
    super.key,
    required this.formKey,
    required this.fullNameController,
    required this.phoneController,
    required this.whatsappController,
    required this.locationController,
    required this.notesController,
    required this.onBackPressed,
    required this.onContinue,
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
                  WebDeliveryHeader(onBackPressed: onBackPressed),
                  const SizedBox(height: 24),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, rowConstraints) {
                        final sideWidth = (rowConstraints.maxWidth * 0.30)
                            .clamp(280.0, 380.0);
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                child: _buildAddressForm(),
                              ),
                            ),
                            const SizedBox(width: 28),
                            SizedBox(
                              width: sideWidth,
                              child: _buildSummarySidebar(),
                            ),
                          ],
                        );
                      },
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

  Widget _buildAddressForm() {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomText(
            text: 'Delivery Address',
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 20,
            textColor: AppColors.primary,
          ),
          const SizedBox(height: 16),
          WebDeliveryTextField(
            controller: fullNameController,
            hint: 'full name',
            suffixIcon: Image.asset(
              AppAssets.contactsIcon,
              width: 22,
              height: 22,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Full name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          WebDeliveryTextField(
            controller: phoneController,
            hint: 'phone number',
            suffixIcon: const Icon(
              Ionicons.call,
              size: 22,
              color: AppColors.iconColor,
            ),
            keyboardType: TextInputType.phone,
            validator: (value) => PhoneValidator.validateEgyptianPhone(value),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
              PhoneInputFormatter(),
            ],
          ),
          const SizedBox(height: 12),
          WebDeliveryTextField(
            controller: whatsappController,
            hint: 'whatsapp number',
            suffixIcon: Image.asset(
              AppAssets.whatsappIcon,
              width: 22,
              height: 22,
            ),
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
              PhoneInputFormatter(),
            ],
          ),
          const SizedBox(height: 12),
          WebDeliveryTextField(
            controller: locationController,
            hint: 'location',
            suffixIcon: const Icon(
              Icons.location_on,
              size: 22,
              color: AppColors.iconColor,
            ),
            maxLines: 5,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Location is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          WebDeliveryTextField(
            controller: notesController,
            hint: 'additional notes',
            suffixIcon: Image.asset(AppAssets.editIcon, width: 22, height: 22),
            maxLines: 3,
            maxLength: 120,
            inputFormatters: [LengthLimitingTextInputFormatter(120)],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSummarySidebar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const WebEstimatedDeliveryCard(),
        const SizedBox(height: 16),
        CustomButton(
          label: 'continue',
          fontFamily: AppFonts.goudyOldStyle,
          fontSize: 20,
          fontWeight: FontWeight.w400,
          textColor: AppColors.primary,
          backgroundColor: AppColors.incrementButton,
          height: 52,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [],
          onPressed: onContinue,
        ),
      ],
    );
  }
}
