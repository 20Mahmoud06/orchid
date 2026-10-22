import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../features/checkout/cubit/checkout_cubit.dart';
import '../../../../shared/widgets/custom_text.dart';
import 'celebration_bouquet_dialog.dart';
import 'celebration_category_item.dart';
import 'celebration_message_input.dart';

class CelebrationSection extends StatefulWidget {
  const CelebrationSection({super.key});

  @override
  State<CelebrationSection> createState() => _CelebrationSectionState();
}

class _CelebrationSectionState extends State<CelebrationSection> {
  String? _selectedCategory;
  final TextEditingController _messageController = TextEditingController();

  static const _categories = <({String name, String icon})>[
    (name: 'birthday', icon: AppAssets.birthdayIcon),
    (name: 'anniversary', icon: AppAssets.anniversaryIcon),
    (name: 'apology', icon: AppAssets.apologyIcon),
    (name: 'graduation', icon: AppAssets.graduationIcon),
    (name: 'proposal', icon: AppAssets.proposalIcon),
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _onCategoryTap(String name) {
    setState(() {
      if (_selectedCategory == name) {
        _selectedCategory = null; // toggle off
      } else {
        _selectedCategory = name;
        _messageController.text = _getPlaceholderForCategory(name);
      }
    });
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
        return CelebrationBouquetDialog(
          onBuyExisting: () {
            Navigator.of(ctx).pop();
            _goToBouquetOptions(AppRoutes.chooseBouquets);
          },
          onCreateBouquet: () {
            Navigator.of(ctx).pop();
            _goToBouquetOptions(AppRoutes.chooseFlowers);
          },
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
          children: [
            for (final category in _categories)
              CelebrationCategoryItem(
                name: category.name,
                icon: category.icon,
                isSelected: _selectedCategory == category.name,
                onTap: () => _onCategoryTap(category.name),
              ),
          ],
        ),
        if (_selectedCategory != null) ...[
          SizedBox(height: 16.h),
          CelebrationMessageInput(
            controller: _messageController,
            onSend: _onSend,
          ),
        ],
      ],
    );
  }
}
