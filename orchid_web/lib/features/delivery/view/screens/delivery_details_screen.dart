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
import '../widgets/web/web_delivery_widgets.dart';

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
    return LayoutBuilder(
      builder: (context, constraints) {
        // Desktop-first web presentation (>= 768px). Narrow viewports keep the
        // untouched Orchid mobile layout.
        if (constraints.maxWidth >= 768) {
          return _buildWeb(context);
        }
        return _buildMobile(context);
      },
    );
  }

  /// Desktop-first delivery details page (>= 768px). Same colors, copy and
  /// behaviour as the mobile screen — a two-column layout like "my cart": the
  /// address form on the left with the estimated delivery card and the continue
  /// button in the summary sidebar.
  Widget _buildWeb(BuildContext context) {
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
                  WebDeliveryHeader(onBackPressed: widget.onBackPressed),
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
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const CustomText(
                                        text: 'Delivery Address',
                                        fontFamily: AppFonts.goudyOldStyle,
                                        fontSize: 20,
                                        textColor: AppColors.primary,
                                      ),
                                      const SizedBox(height: 16),
                                      WebDeliveryTextField(
                                        controller: _fullNameController,
                                        hint: 'full name',
                                        suffixIcon: Image.asset(
                                          AppAssets.contactsIcon,
                                          width: 22,
                                          height: 22,
                                        ),
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return 'Full name is required';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                      WebDeliveryTextField(
                                        controller: _phoneController,
                                        hint: 'phone number',
                                        suffixIcon: const Icon(
                                          Ionicons.call,
                                          size: 22,
                                          color: AppColors.iconColor,
                                        ),
                                        keyboardType: TextInputType.phone,
                                        validator: (value) =>
                                            PhoneValidator
                                                .validateEgyptianPhone(value),
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                          LengthLimitingTextInputFormatter(11),
                                          PhoneInputFormatter(),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      WebDeliveryTextField(
                                        controller: _whatsappController,
                                        hint: 'whatsapp number',
                                        suffixIcon: Image.asset(
                                          AppAssets.whatsappIcon,
                                          width: 22,
                                          height: 22,
                                        ),
                                        keyboardType: TextInputType.phone,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                          LengthLimitingTextInputFormatter(11),
                                          PhoneInputFormatter(),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      WebDeliveryTextField(
                                        controller: _locationController,
                                        hint: 'location',
                                        suffixIcon: const Icon(
                                          Icons.location_on,
                                          size: 22,
                                          color: AppColors.iconColor,
                                        ),
                                        maxLines: 5,
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return 'Location is required';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                      WebDeliveryTextField(
                                        controller: _notesController,
                                        hint: 'additional notes',
                                        suffixIcon: Image.asset(
                                          AppAssets.editIcon,
                                          width: 22,
                                          height: 22,
                                        ),
                                        maxLines: 3,
                                        maxLength: 120,
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(
                                              120),
                                        ],
                                      ),
                                      const SizedBox(height: 24),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 28),
                            SizedBox(
                              width: sideWidth,
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.stretch,
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
                                    onPressed:
                                        widget.onContinue ?? _handleContinue,
                                  ),
                                ],
                              ),
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

  /// Mobile layout (unchanged).
  Widget _buildMobile(BuildContext context) {
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