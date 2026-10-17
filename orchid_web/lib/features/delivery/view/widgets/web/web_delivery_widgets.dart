import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_fonts.dart';
import '../../../../../features/checkout/cubit/checkout_cubit.dart';
import '../../../../../shared/widgets/custom_text.dart';

/// Desktop-first building blocks for the Delivery Details page.
///
/// Presentation only: the colors, copy and behaviour mirror the mobile screen
/// exactly, sized in fixed logical pixels (the web app pins the design size, so
/// these render 1:1 on any monitor).

/// Centered "Delivery Details" title.
class WebDeliveryHeader extends StatelessWidget {
  final VoidCallback? onBackPressed;

  const WebDeliveryHeader({super.key, this.onBackPressed});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 36,
      child: Center(
        child: CustomText(
          text: 'Delivery Details',
          fontFamily: AppFonts.goudyOldStyle,
          fontSize: 24,
          textColor: AppColors.black,
        ),
      ),
    );
  }
}

/// "Estimated Delivery" info card matching the mobile card.
class WebEstimatedDeliveryCard extends StatelessWidget {
  final String? date;
  final String? timeRange;

  const WebEstimatedDeliveryCard({
    super.key,
    this.date,
    this.timeRange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Row(
        children: [
          Image.asset(
            AppAssets.calendarIcon,
            width: 56,
            height: 56,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomText(
                  text: 'Estimated Delivery',
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 18,
                  textColor: AppColors.textGrey,
                ),
                const SizedBox(height: 4),
                CustomText(
                  text: date ?? CheckoutCubit.instance.deliveryDate,
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 18,
                  textColor: AppColors.black,
                ),
                const SizedBox(height: 2),
                CustomText(
                  text: timeRange ?? CheckoutCubit.instance.deliveryTime,
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 18,
                  textColor: AppColors.textPrimary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// White rounded text field with a focus-driven pink border and an optional
/// suffix icon (Widget), matching the mobile [DeliveryTextField].
class WebDeliveryTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final Widget? suffixIcon;
  final int maxLines;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;

  const WebDeliveryTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.suffixIcon,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.inputFormatters,
    this.maxLength,
  });

  @override
  State<WebDeliveryTextField> createState() => _WebDeliveryTextFieldState();
}

class _WebDeliveryTextFieldState extends State<WebDeliveryTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (mounted) {
        setState(() => _isFocused = _focusNode.hasFocus);
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
        color: _isFocused ? AppColors.selectedCategory : AppColors.cardBorder,
        width: _isFocused ? 2 : 1,
      ),
    );
    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.error, width: 1.5),
    );

    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      inputFormatters: widget.inputFormatters,
      style: const TextStyle(
        fontFamily: AppFonts.goudyOldStyle,
        fontSize: 15,
        color: AppColors.black,
      ),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: TextStyle(
          fontFamily: AppFonts.goudyOldStyle,
          fontSize: 15,
          color: AppColors.black.withValues(alpha: 0.5),
        ),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: border,
        enabledBorder: border,
        focusedBorder: border,
        errorBorder: errorBorder,
        focusedErrorBorder: errorBorder,
        suffixIcon: widget.suffixIcon == null
            ? null
            : Padding(
                padding: EdgeInsets.only(
                  right: 10,
                  top: widget.maxLines > 1 ? 10 : 0,
                ),
                child: Align(
                  alignment: widget.maxLines > 1
                      ? Alignment.topCenter
                      : Alignment.center,
                  widthFactor: 1,
                  heightFactor: 1,
                  child: widget.suffixIcon,
                ),
              ),
        suffixIconConstraints: widget.suffixIcon != null
            ? const BoxConstraints(minWidth: 40, minHeight: 40)
            : null,
      ),
    );
  }
}
