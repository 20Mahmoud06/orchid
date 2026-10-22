import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../core/utils/phone_formatter.dart';
import '../../../../core/validators/phone_validator.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text.dart';
import 'delivery_text_field.dart';
import 'estimated_delivery_card.dart';

/// Mobile layout of the delivery-details screen (unchanged presentation).
class DeliveryDetailsMobileView extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController fullNameController;
  final TextEditingController phoneController;
  final TextEditingController whatsappController;
  final TextEditingController locationController;
  final TextEditingController notesController;
  final VoidCallback? onBackPressed;
  final VoidCallback onContinue;

  const DeliveryDetailsMobileView({
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
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: Column(
            children: [
              CustomAppBar.orchid(
                title: 'Delivery Details',
                showBackButton: false,
                onBackPressed: onBackPressed,
              ),
              SizedBox(height: 20.h),
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const EstimatedDeliveryCard(),
                        SizedBox(height: 24.h),
                        CustomText(
                          text: 'Delivery Address',
                          fontFamily: AppFonts.goudyOldStyle,
                          fontSize: 20.sp,
                          textColor: AppColors.primary,
                        ),
                        SizedBox(height: 16.h),
                        DeliveryTextField(
                          controller: fullNameController,
                          hint: 'full name',
                          suffixIcon: Image.asset(
                            AppAssets.contactsIcon,
                            width: 22.r,
                            height: 22.r,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Full name is required';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 12.h),
                        DeliveryTextField(
                          controller: phoneController,
                          hint: 'phone number',
                          suffixIcon: Icon(
                            Ionicons.call,
                            size: 22.r,
                            color: AppColors.iconColor,
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) =>
                              PhoneValidator.validateEgyptianPhone(value),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(11),
                            PhoneInputFormatter(),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        DeliveryTextField(
                          controller: whatsappController,
                          hint: 'whatsapp number',
                          suffixIcon: Image.asset(
                            AppAssets.whatsappIcon,
                            width: 22.r,
                            height: 22.r,
                          ),
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(11),
                            PhoneInputFormatter(),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        DeliveryTextField(
                          controller: locationController,
                          hint: 'location',
                          suffixIcon: Icon(
                            Icons.location_on,
                            size: 22.r,
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
                        SizedBox(height: 12.h),
                        DeliveryTextField(
                          controller: notesController,
                          hint: 'additional notes',
                          suffixIcon: Image.asset(
                            AppAssets.editIcon,
                            width: 22.r,
                            height: 22.r,
                          ),
                          maxLines: 3,
                          maxLength: 120,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(120),
                          ],
                        ),
                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),
              ),
              CustomButton(
                label: 'continue',
                fontFamily: AppFonts.goudyOldStyle,
                fontSize: 20.sp,
                fontWeight: FontWeight.w400,
                textColor: AppColors.primary,
                backgroundColor: AppColors.incrementButton,
                height: 52.h,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: const [],
                onPressed: onContinue,
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
