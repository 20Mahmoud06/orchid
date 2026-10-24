import 'package:flutter/material.dart';

import 'package:ORCHID/core/constants/app_assets.dart';
import 'package:ORCHID/core/constants/app_colors.dart';
import 'package:ORCHID/core/constants/app_fonts.dart';
import 'package:ORCHID/core/router/app_routes.dart';
import 'package:ORCHID/features/checkout/cubit/checkout_cubit.dart';

import 'web_bouquet_options_dialog.dart';
import 'web_occasion_circle_item.dart';
import 'web_occasion_message_input.dart';
import '../../../../../shared/widgets/custom_text.dart';

/// 'Shop by occasion' section with centered divider title and 5 circular occasion items.
/// When an occasion is selected, shows a message input field and send action just like mobile.
class WebOccasionsSection extends StatefulWidget {
  const WebOccasionsSection({super.key});

  @override
  State<WebOccasionsSection> createState() => _WebOccasionsSectionState();
}

class _WebOccasionsSectionState extends State<WebOccasionsSection> {
  String? _selectedCategory;
  final TextEditingController _messageController = TextEditingController();

  static const _occasions = <({String key, String name, String icon})>[
    (key: 'birthday', name: 'Birthday', icon: AppAssets.birthdayIcon),
    (key: 'anniversary', name: 'Anniversary', icon: AppAssets.anniversaryIcon),
    (key: 'apology', name: 'Apology', icon: AppAssets.apologyIcon),
    (key: 'graduation', name: 'Graduation', icon: AppAssets.graduationIcon),
    (key: 'proposal', name: 'Proposal', icon: AppAssets.proposalIcon),
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  String _getPlaceholderForCategory(String categoryKey) {
    switch (categoryKey) {
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

  void _onOccasionTapped(String key) {
    setState(() {
      if (_selectedCategory == key) {
        _selectedCategory = null;
        _messageController.clear();
      } else {
        _selectedCategory = key;
        _messageController.text = _getPlaceholderForCategory(key);
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
        return WebBouquetOptionsDialog(
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Section Title with flanking dividers
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 44, height: 1, color: AppColors.storeDivider),
            const SizedBox(width: 14),
            const CustomText(
              text: 'Shop by occasion',
              fontFamily: AppFonts.goudyOldStyle,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              textColor: AppColors.storeDeepGreen,
            ),
            const SizedBox(width: 14),
            Container(width: 44, height: 1, color: AppColors.storeDivider),
          ],
        ),
        const SizedBox(height: 28),

        // Occasion circular avatars row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < _occasions.length; i++) ...[
                if (i > 0) const SizedBox(width: 32),
                WebOccasionCircleItem(
                  name: _occasions[i].name,
                  iconAsset: _occasions[i].icon,
                  isSelected: _selectedCategory == _occasions[i].key,
                  onTap: () => _onOccasionTapped(_occasions[i].key),
                ),
              ],
            ],
          ),
        ),

        // Occasion Message Text Field (Shown when an occasion is tapped)
        if (_selectedCategory != null) ...[
          const SizedBox(height: 24),
          WebOccasionMessageInput(
            controller: _messageController,
            onSend: _onSend,
          ),
        ],
      ],
    );
  }
}
