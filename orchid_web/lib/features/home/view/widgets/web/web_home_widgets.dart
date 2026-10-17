import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import 'package:ORCHID/core/constants/app_assets.dart';
import 'package:ORCHID/core/constants/app_colors.dart';
import 'package:ORCHID/core/constants/app_fonts.dart';
import 'package:ORCHID/core/router/app_routes.dart';
import 'package:ORCHID/features/checkout/cubit/checkout_cubit.dart';
import 'package:ORCHID/shared/widgets/skeleton_image.dart';

/// Centered content section wrapper with responsive horizontal padding and
/// a max width constraint of 1240 logical pixels.
class WebStoreSection extends StatelessWidget {
  final Widget child;
  final double verticalPadding;

  const WebStoreSection({
    super.key,
    required this.child,
    this.verticalPadding = 24,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontal = constraints.maxWidth >= 1024 ? 48.0 : 20.0;
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontal,
            vertical: verticalPadding,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1240),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

/// Large Hero section with soft blush pink card, balanced 2-column layout,
/// prominent headline, supporting description, two CTA buttons, and floral imagery.
class WebHeroSection extends StatelessWidget {
  const WebHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 900;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.storeBlush,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.storeBlushBorder, width: 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: isCompact ? _buildCompact(context) : _buildWide(context),
        );
      },
    );
  }

  Widget _buildWide(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left Column: Text & Buttons
        Expanded(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(48, 44, 24, 44),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'FLOWERS FOR EVERY MOMENT',
                  style: TextStyle(
                    fontFamily: AppFonts.inriaSerif,
                    fontSize: 11,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.storeEyebrow,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Make someone’s\nday bloom.',
                  style: TextStyle(
                    fontFamily: AppFonts.goudyOldStyle,
                    fontSize: 44,
                    height: 1.15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.storeDeepGreen,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Fresh flowers, thoughtful bouquets, and little\nmoments of happiness — delivered to their door.',
                  style: TextStyle(
                    fontFamily: AppFonts.inriaSerif,
                    fontSize: 15,
                    height: 1.45,
                    color: AppColors.storeBodyText,
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _PillButton(
                      label: 'Shop flowers  →',
                      filled: true,
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.chooseFlowers),
                    ),
                    const SizedBox(width: 14),
                    _PillButton(
                      label: 'Build a bouquet  →',
                      filled: false,
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.chooseFlowers),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Right Column: Bouquet Image
        Expanded(
          flex: 5,
          child: SizedBox(
            height: 380,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Image.asset(
                AppAssets.bouquetTest,
                fit: BoxFit.contain,
                alignment: Alignment.centerRight,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompact(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'FLOWERS FOR EVERY MOMENT',
            style: TextStyle(
              fontFamily: AppFonts.inriaSerif,
              fontSize: 11,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
              color: AppColors.storeEyebrow,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Make someone’s day bloom.',
            style: TextStyle(
              fontFamily: AppFonts.goudyOldStyle,
              fontSize: 32,
              height: 1.2,
              fontWeight: FontWeight.bold,
              color: AppColors.storeDeepGreen,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Fresh flowers, thoughtful bouquets, and little moments of happiness — delivered to their door.',
            style: TextStyle(
              fontFamily: AppFonts.inriaSerif,
              fontSize: 14,
              height: 1.4,
              color: AppColors.storeBodyText,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              height: 220,
              child: Image.asset(AppAssets.bouquetTest, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _PillButton(
                label: 'Shop flowers  →',
                filled: true,
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.chooseFlowers),
              ),
              _PillButton(
                label: 'Build a bouquet  →',
                filled: false,
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.chooseFlowers),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Pill button component used in the hero and promotional sections.
class _PillButton extends StatefulWidget {
  final String label;
  final bool filled;
  final VoidCallback onTap;

  const _PillButton({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  @override
  State<_PillButton> createState() => _PillButtonState();
}

class _PillButtonState extends State<_PillButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    const brandGreen = AppColors.storeDeepGreen;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          decoration: BoxDecoration(
            color: widget.filled
                ? (_hovered ? AppColors.storeGreenHover : brandGreen)
                : (_hovered
                      ? brandGreen.withValues(alpha: 0.08)
                      : Colors.transparent),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: brandGreen, width: 1.2),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontFamily: AppFonts.inriaSerif,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: widget.filled ? Colors.white : brandGreen,
            ),
          ),
        ),
      ),
    );
  }
}

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
    (key: 'proposal', name: 'Just Because', icon: AppAssets.proposalIcon),
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
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: AppColors.background,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: AppColors.textFieldPink,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Ionicons.gift_outline,
                      size: 32,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Your Message Is Ready',
                    style: TextStyle(
                      fontFamily: AppFonts.goudyOldStyle,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Choose a bouquet for your celebration. Buy an existing bouquet or create your own.',
                    style: TextStyle(
                      fontFamily: AppFonts.inriaSerif,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        _goToBouquetOptions(AppRoutes.chooseBouquets);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.textFieldPink,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'BUY EXISTING BOUQUET',
                        style: TextStyle(
                          fontFamily: AppFonts.goudyOldStyle,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        _goToBouquetOptions(AppRoutes.chooseFlowers);
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(
                          color: AppColors.storeOutlineBorder,
                        ),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'CREATE MY BOUQUET',
                        style: TextStyle(
                          fontFamily: AppFonts.goudyOldStyle,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
            const Text(
              'Shop by occasion',
              style: TextStyle(
                fontFamily: AppFonts.goudyOldStyle,
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.storeDeepGreen,
              ),
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
                _OccasionCircleItem(
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
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.storeOutlineBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 6),
                    const Icon(
                      Ionicons.create_outline,
                      size: 20,
                      color: AppColors.storeIconMuted,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        autofocus: true,
                        style: const TextStyle(
                          fontFamily: AppFonts.inriaSerif,
                          fontSize: 14,
                          color: AppColors.black,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Type your message...',
                          hintStyle: TextStyle(
                            fontFamily: AppFonts.inriaSerif,
                            fontSize: 14,
                            color: AppColors.storeHintText,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                        onSubmitted: (_) => _onSend(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: _onSend,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.textFieldDarkerPink,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Send',
                            style: TextStyle(
                              fontFamily: AppFonts.inriaSerif,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkGreen,
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
        ],
      ],
    );
  }
}

class _OccasionCircleItem extends StatefulWidget {
  final String name;
  final String iconAsset;
  final bool isSelected;
  final VoidCallback onTap;

  const _OccasionCircleItem({
    required this.name,
    required this.iconAsset,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_OccasionCircleItem> createState() => _OccasionCircleItemState();
}

class _OccasionCircleItemState extends State<_OccasionCircleItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.isSelected || _hovered;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              transform: Matrix4.translationValues(0, active ? -4 : 0, 0),
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.isSelected
                    ? AppColors.textFieldPink
                    : AppColors.storeCircleBg,
                border: Border.all(
                  color: active
                      ? AppColors.storeRose
                      : AppColors.storeCircleBorder,
                  width: widget.isSelected ? 2.5 : 2,
                ),
                boxShadow: [
                  if (active)
                    BoxShadow(
                      color: AppColors.storeRose.withValues(alpha: 0.18),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: ClipOval(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Image.asset(widget.iconAsset, fit: BoxFit.contain),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.name,
              style: TextStyle(
                fontFamily: AppFonts.inriaSerif,
                fontSize: 14,
                fontWeight: widget.isSelected
                    ? FontWeight.bold
                    : FontWeight.w500,
                color: widget.isSelected
                    ? AppColors.storeRose
                    : AppColors.storeLabel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Popular product item card matching the 4-card grid in the reference image.
class WebPopularProductCard extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String price;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onToggle;

  const WebPopularProductCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.price,
    this.isFavorite = false,
    this.onTap,
    this.onToggle,
  });

  @override
  State<WebPopularProductCard> createState() => _WebPopularProductCardState();
}

class _WebPopularProductCardState extends State<WebPopularProductCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hovered
                ? AppColors.storeRose.withValues(alpha: 0.4)
                : AppColors.storeCardBorder,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _hovered ? 0.08 : 0.03),
              blurRadius: _hovered ? 14 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Image with heart toggle overlay — fills the card exactly
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        widget.imageUrl.startsWith('http')
                            ? SkeletonImage(
                                path: widget.imageUrl,
                                fit: BoxFit.cover,
                                placeholderColor: AppColors.fieldPink,
                                errorWidget: Image.asset(
                                  AppAssets.circleFlower,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Image.asset(
                                widget.imageUrl.isNotEmpty
                                    ? widget.imageUrl
                                    : AppAssets.circleFlower,
                                fit: BoxFit.cover,
                              ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: widget.onToggle,
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      Colors.white.withValues(alpha: 0.85),
                                ),
                                child: Center(
                                  child: Icon(
                                    widget.isFavorite
                                        ? Ionicons.heart
                                        : Ionicons.heart_outline,
                                    size: 17,
                                    color: widget.isFavorite
                                        ? AppColors.storeRose
                                        : AppColors.iconColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Content: Title & Price
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: AppFonts.goudyOldStyle,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.storeDeepGreen,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.price,
                        style: const TextStyle(
                          fontFamily: AppFonts.inriaSerif,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.storeDeepGreen,
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
    );
  }
}

/// Backwards-compatible alias for WebProductCard.
class WebProductCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String price;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onToggle;

  const WebProductCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.price,
    this.isFavorite = false,
    this.onTap,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return WebPopularProductCard(
      imageUrl: imageUrl,
      title: title,
      price: price,
      isFavorite: isFavorite,
      onTap: onTap,
      onToggle: onToggle,
    );
  }
}

/// Primary button component.
class WebPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Color? color;
  final double? width;

  const WebPrimaryButton({
    super.key,
    required this.label,
    this.onTap,
    this.color,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: SizedBox(
        width: width,
        height: 54,
        child: Material(
          color: color ?? AppColors.buttonPink,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontFamily: AppFonts.inriaSerif,
                    fontSize: 18,
                    color: AppColors.darkGreen,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Promotional section for the custom bouquet builder matching the reference image:
/// Blush pink banner with headline, description, button, and tulips on the right.
class WebCustomBouquetBanner extends StatelessWidget {
  const WebCustomBouquetBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 800;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.storeBlush,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.storeBlushBorder, width: 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: isCompact ? _buildCompact(context) : _buildWide(context),
        );
      },
    );
  }

  Widget _buildWide(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left text & button
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(40, 24, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Build a bouquet that feels like you',
                    style: TextStyle(
                      fontFamily: AppFonts.goudyOldStyle,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.storeDeepGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Choose your favorite flowers, add a personal touch,\nand create something truly special.',
                    style: TextStyle(
                      fontFamily: AppFonts.inriaSerif,
                      fontSize: 13,
                      height: 1.35,
                      color: AppColors.storeBodyText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _PillButton(
                    label: 'Start creating  →',
                    filled: true,
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.chooseFlowers),
                  ),
                ],
              ),
            ),
          ),

          // Right floral graphic (pink tulips from buildFlower.jpg)
          Expanded(
            flex: 5,
            child: Image.asset(
              AppAssets.buildFlower,
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompact(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Build a bouquet that feels like you',
            style: TextStyle(
              fontFamily: AppFonts.goudyOldStyle,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.storeDeepGreen,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose your favorite flowers, add a personal touch, and create something truly special.',
            style: TextStyle(
              fontFamily: AppFonts.inriaSerif,
              fontSize: 13,
              height: 1.35,
              color: AppColors.storeBodyText,
            ),
          ),
          const SizedBox(height: 16),
          _PillButton(
            label: 'Start creating  →',
            filled: true,
            onTap: () => Navigator.pushNamed(context, AppRoutes.chooseFlowers),
          ),
        ],
      ),
    );
  }
}

/// Storefront footer matching the reference design layout:
/// - Brand info & social media channels
/// - Shop column
/// - Help column
/// - About column
/// - Privacy Policy & Terms links
/// - Copyright row
class WebHomeFooter extends StatelessWidget {
  const WebHomeFooter({super.key});

  void _go(BuildContext context, String route) {
    Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF7DDE2), width: 1)),
      ),
      child: WebStoreSection(
        verticalPadding: 36,
        child: Column(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 860;

                if (isCompact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBrandCol(context),
                      const SizedBox(height: 28),
                      Wrap(
                        spacing: 48,
                        runSpacing: 24,
                        children: [
                          _buildShopCol(context),
                          _buildSupportCol(context),
                          _buildAboutCol(context),
                        ],
                      ),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 4, child: _buildBrandCol(context)),
                    Expanded(flex: 2, child: _buildShopCol(context)),
                    Expanded(flex: 3, child: _buildSupportCol(context)),
                    Expanded(flex: 3, child: _buildAboutCol(context)),
                  ],
                );
              },
            ),
            const SizedBox(height: 36),
            const Divider(color: Color(0xFFF5E4E4), height: 1),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '© 2026 ORCHID. All rights reserved.',
                  style: TextStyle(
                    fontFamily: AppFonts.inriaSerif,
                    fontSize: 12,
                    color: Color(0xFF8C9B94),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      AppAssets.flowerOutlineIcon,
                      color: AppColors.storeRose,
                      height: 18,
                      width: 18,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 1,
                      height: 12,
                      color: const Color(0xFFE2D4D2),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Made with care, for life\'s little moments.',
                      style: TextStyle(
                        fontFamily: AppFonts.inriaSerif,
                        fontSize: 12,
                        color: Color(0xFF8C9B94),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColumnHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E352D),
          ),
        ),
        const SizedBox(height: 6),
        Container(width: 24, height: 1.5, color: const Color(0xFFE8D7D5)),
      ],
    );
  }

  Widget _buildBrandCol(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              AppAssets.flowerOutlineIcon,
              color: AppColors.storeRose,
              height: 28,
              width: 28,
            ),
            const SizedBox(width: 10),
            const Text(
              'ORCHID',
              style: TextStyle(
                fontFamily: AppFonts.goudyOldStyle,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.8,
                color: Color(0xFF1E352D),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Thoughtful flowers for a\nbrighter tomorrow.',
          style: TextStyle(
            fontFamily: AppFonts.inriaSerif,
            fontSize: 13,
            color: Color(0xFF4A5C54),
            height: 1.45,
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: const [
            _SocialIcon(icon: Ionicons.logo_facebook),
            SizedBox(width: 14),
            _SocialIcon(icon: Ionicons.logo_instagram),
            SizedBox(width: 14),
            _SocialIcon(icon: Ionicons.logo_tiktok),
          ],
        ),
      ],
    );
  }

  Widget _buildShopCol(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildColumnHeader('Shop'),
        const SizedBox(height: 14),
        _FooterLink(
          label: 'Flowers',
          onTap: () => _go(context, AppRoutes.chooseFlowers),
        ),
        const SizedBox(height: 10),
        _FooterLink(
          label: 'Bouquets',
          onTap: () => _go(context, AppRoutes.chooseBouquets),
        ),
        const SizedBox(height: 10),
        _FooterLink(
          label: 'Inspiration',
          onTap: () => _go(context, AppRoutes.inspiration),
        ),
      ],
    );
  }

  Widget _buildSupportCol(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildColumnHeader('Account & Support'),
        const SizedBox(height: 14),
        _FooterLink(
          label: 'Contact Us',
          onTap: () => _go(context, AppRoutes.contactUs),
        ),
        const SizedBox(height: 10),
        _FooterLink(
          label: 'Order History',
          onTap: () => _go(context, AppRoutes.orderHistory),
        ),
        const SizedBox(height: 10),
        _FooterLink(
          label: 'My Account',
          onTap: () => _go(context, AppRoutes.profile),
        ),
      ],
    );
  }

  Widget _buildAboutCol(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildColumnHeader('About Orchid'),
        const SizedBox(height: 14),
        _FooterLink(
          label: 'About App',
          onTap: () => _go(context, AppRoutes.aboutApp),
        ),
        const SizedBox(height: 10),
        _FooterLink(
          label: 'Privacy Policy',
          onTap: () => _go(context, AppRoutes.privacyPolicy),
        ),
        const SizedBox(height: 10),
        _FooterLink(
          label: 'Terms & Conditions',
          onTap: () => _go(context, AppRoutes.termsConditions),
        ),
      ],
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;

  const _SocialIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Icon(icon, size: 17, color: AppColors.storeDeepGreen),
    );
  }
}

class _FooterLink extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _FooterLink({required this.label, required this.onTap});

  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Text(
          widget.label,
          style: TextStyle(
            fontFamily: AppFonts.inriaSerif,
            fontSize: 13,
            color: _hovered ? AppColors.storeRose : AppColors.storeFooterText,
          ),
        ),
      ),
    );
  }
}
