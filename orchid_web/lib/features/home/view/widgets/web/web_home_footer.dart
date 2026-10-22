import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:ORCHID/core/constants/app_assets.dart';
import 'package:ORCHID/core/constants/app_colors.dart';
import 'package:ORCHID/core/constants/app_fonts.dart';
import 'package:ORCHID/core/router/app_routes.dart';
import 'package:ORCHID/features/home/view/widgets/web/web_store_section.dart';

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
