import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ionicons/ionicons.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../features/checkout/cubit/checkout_cubit.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/phone_formatter.dart';
import '../../../../core/validators/phone_validator.dart';
import '../../../../features/auth/cubit/auth_cubit.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text.dart';
import '../widgets/delivery_text_field.dart';
import '../widgets/estimated_delivery_card.dart';

/// Delivery details screen matching the Orchid Figma design.
class DeliveryDetailsScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;
  final VoidCallback? onContinue;

  const DeliveryDetailsScreen({
    super.key,
    this.onBackPressed,
    this.onContinue,
  });

  @override
  State<DeliveryDetailsScreen> createState() => _DeliveryDetailsScreenState();
}

class _DeliveryDetailsScreenState extends State<DeliveryDetailsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final profile = AuthCubit.instance.userProfile;
    if (profile != null) {
      _fullNameController.text = profile.username ?? '';
      _phoneController.text = profile.phone ?? '';
      _whatsappController.text = profile.whatsapp ?? '';
      _locationController.text = profile.address ?? '';
    }
  }

  void _handleContinue() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    CheckoutCubit.instance.setDeliveryDetails(
      fullName: _fullNameController.text,
      phone: _phoneController.text,
      whatsapp: _whatsappController.text,
      location: _locationController.text,
      notes: _notesController.text,
    );
    Navigator.pushNamed(context, AppRoutes.orderSummary);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

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
                onBackPressed: widget.onBackPressed,
              ),
              SizedBox(height: 20.h),
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
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
                          controller: _fullNameController,
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
                          controller: _phoneController,
                          hint: 'phone number',
                          suffixIcon: Icon(
                            Ionicons.call,
                            size: 22.r,
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
                        SizedBox(height: 12.h),
                        DeliveryTextField(
                          controller: _whatsappController,
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
                          controller: _locationController,
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
                          controller: _notesController,
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
                onPressed: widget.onContinue ?? _handleContinue,
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}