import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ionicons/ionicons.dart';
import '../../../../features/checkout/cubit/checkout_cubit.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../shared/widgets/custom_text.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/custom_button.dart';

class CelebrationSection extends StatefulWidget {
  const CelebrationSection({super.key});

  @override
  State<CelebrationSection> createState() => _CelebrationSectionState();
}

class _CelebrationSectionState extends State<CelebrationSection> {
  String? _selectedCategory;
  final TextEditingController _messageController = TextEditingController();

  final List<Map<String, String>> categories = [
    {'name': 'birthday', 'icon': AppAssets.birthdayIcon},
    {'name': 'anniversary', 'icon': AppAssets.anniversaryIcon},
    {'name': 'apology', 'icon': AppAssets.apologyIcon},
    {'name': 'graduation', 'icon': AppAssets.graduationIcon},
    {'name': 'proposal', 'icon': AppAssets.proposalIcon},
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _onSend() {
    CheckoutCubit.instance.setMessage(
      hasMessage: true,
      text: _messageController.text,
    );
    _showBouquetOptionsDialog();
  }

  Future<void> _showBouquetOptionsDialog() {
    return showDialog<void>(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          backgroundColor: AppColors.background,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64.r,
                  height: 64.r,
                  decoration: BoxDecoration(
                    color: AppColors.textFieldPink,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Ionicons.gift_outline,
                    size: 32.r,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: 16.h),
                CustomText(
                  text: 'Your Message Is Ready',
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  textColor: AppColors.black,
                ),
                SizedBox(height: 12.h),
                CustomText(
                  text:
                      'Choose a bouquet for your celebration. Buy an existing bouquet or create your own.',
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 14.sp,
                  textColor: AppColors.textPrimary,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.h),
                CustomButton(
                  label: 'BUY EXISTING BOUQUET',
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  textColor: AppColors.black,
                  backgroundColor: AppColors.textFieldPink,
                  height: 48.h,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: const [],
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _goToBouquetOptions(AppRoutes.chooseBouquets);
                  },
                ),
                SizedBox(height: 12.h),
                CustomButton(
                  label: 'CREATE MY BOUQUET',
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  textColor: AppColors.black,
                  backgroundColor: AppColors.white,
                  height: 48.h,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: const [],
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _goToBouquetOptions(AppRoutes.chooseFlowers);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _goToBouquetOptions(String route) {
    setState(() {
      _selectedCategory = null;
      _messageController.clear();
    });
    Navigator.pushNamed(context, route);
  }

  String _getPlaceholderForCategory(String category) {
    switch (category) {
      case 'birthday':
          return 'Wishing a Happy Birthday to ';
      case 'anniversary':
        return 'Another year of love with ';
      case 'apology':
        return 'Sending my sincerest apologies to ';
      case 'graduation':
        return 'Congratulations on your big day, ';
      case 'proposal':
        return 'Will you be mine forever? ';
      default:
        return 'A special message for ';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: 'what are you celebrating?',
          fontFamily: AppFonts.goudyOldStyle,
          fontSize: 20.sp,
          textColor: AppColors.black,
        ),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: categories.map((cat) {
            final isSelected = _selectedCategory == cat['name'];
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedCategory = null; // toggle off
                    _messageController.clear();
                  } else {
                    _selectedCategory = cat['name'];
                    _messageController.text = _getPlaceholderForCategory(cat['name']!);
                  }
                });
              },
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? AppColors.textFieldPink : Colors.transparent,
                    ),
                    child: Image.asset(
                      cat['icon']!,
                      width: 40.r,
                      height: 40.r,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  CustomText(
                    text: cat['name']!,
                    fontFamily: AppFonts.goudyOldStyle,
                    fontSize: 12.sp,
                    textColor: AppColors.black,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        if (_selectedCategory != null) ...[
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _messageController,
                  hint: 'Type your message...',
                  containerColor: AppColors.white,
                  fillColor: AppColors.white,
                  boxShadow: const [],
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  borderRadius: 16.r,
                ),
              ),
              SizedBox(width: 8.w),
              CustomButton(
                label: 'Send',
                width: 80.w,
                height: 48.h,
                backgroundColor: AppColors.textFieldDarkerPink,
                textColor: AppColors.darkGreen,
                fontSize: 14.sp,
                boxShadow: const [],
                onPressed: _onSend,
              ),
            ],
          ),
        ],
      ],
    );
  }
}
