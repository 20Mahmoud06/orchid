import 'package:flutter/material.dart';

import 'package:ORCHID/core/constants/app_colors.dart';
import 'package:ORCHID/core/constants/app_fonts.dart';
import 'package:ORCHID/features/auth/data/models/user_profile_model.dart';
import 'package:ORCHID/features/profile/view/widgets/profile_avatar.dart';

/// Desktop-first Profile widgets.
///
/// These only own presentation: the colors, copy and behaviour mirror the
/// mobile profile screen exactly. Sizing uses fixed logical pixels (not
/// `flutter_screenutil`) because on the web the app pins the design size, so
/// these values render 1:1 on any monitor — the same convention as the other
/// web pages.

/// The rounded profile card: avatar, name/email, an Edit button and the info
/// fields laid out as a two-column grid on wide screens.
class WebProfileCard extends StatelessWidget {
  final String displayName;
  final String displayEmail;
  final String? imageUrl;
  final UserProfileModel? profile;
  final VoidCallback onEdit;

  const WebProfileCard({
    super.key,
    required this.displayName,
    required this.displayEmail,
    required this.imageUrl,
    required this.profile,
    required this.onEdit,
  });

  String _displayValue(String? value) {
    if (value == null || value.trim().isEmpty) return '-';
    return value.trim();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _ProfileAvatar(imageUrl: imageUrl, onTap: onEdit),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontFamily: AppFonts.goudyOldStyle,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      displayEmail,
                      style: TextStyle(
                        fontFamily: AppFonts.goudyOldStyle,
                        fontSize: 13,
                        color: Colors.black.withValues(alpha: 0.75),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _EditButton(onTap: onEdit),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(color: AppColors.cardBorder, height: 1),
          const SizedBox(height: 20),
          _InfoGrid(
            children: [
              _InfoField(
                label: 'Username',
                value: _displayValue(profile?.username),
              ),
              _InfoField(
                label: 'Phone Number',
                value: _displayValue(profile?.phone),
              ),
              _InfoField(
                label: 'Whatsapp Number',
                value: _displayValue(profile?.whatsapp),
              ),
              _InfoField(
                label: 'Delivery Address',
                value: _displayValue(profile?.address),
                showArrow: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final VoidCallback onTap;

  const _ProfileAvatar({required this.imageUrl, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.background,
                border: Border.all(color: AppColors.cardBorder, width: 1.5),
              ),
              child: ClipOval(
                child: ProfileAvatarImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.black12),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 15,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditButton extends StatelessWidget {
  final VoidCallback onTap;

  const _EditButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.cardBorder,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            'Edit',
            style: TextStyle(
              fontFamily: AppFonts.goudyOldStyle,
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.black,
            ),
          ),
        ),
      ),
    );
  }
}

/// Two-column field grid that collapses to a single column on narrow cards.
class _InfoGrid extends StatelessWidget {
  final List<Widget> children;

  const _InfoGrid({required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 460) {
          return Column(children: _stacked());
        }

        final rows = <Widget>[];
        for (var i = 0; i < children.length; i += 2) {
          final left = children[i];
          final right = i + 1 < children.length
              ? children[i + 1]
              : const SizedBox.shrink();
          final isLast = i + 2 >= children.length;
          rows.add(
            Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: left),
                  const SizedBox(width: 28),
                  Expanded(child: right),
                ],
              ),
            ),
          );
        }
        return Column(children: rows);
      },
    );
  }

  List<Widget> _stacked() {
    return [
      for (var i = 0; i < children.length; i++) ...[
        children[i],
        if (i + 1 < children.length) const SizedBox(height: 18),
      ],
    ];
  }
}

class _InfoField extends StatelessWidget {
  final String label;
  final String value;
  final bool showArrow;

  const _InfoField({
    required this.label,
    required this.value,
    this.showArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: AppFonts.inriaSerif,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkGreen,
                ),
              ),
            ),
            if (showArrow) ...[
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: AppColors.darkGreen,
              ),
            ],
          ],
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            fontFamily: AppFonts.inriaSerif,
            fontSize: 15,
            color: Colors.black.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

/// Full-width desktop action button (Log Out / Delete Account).
class WebProfileActionButton extends StatelessWidget {
  final String label;
  final Widget? icon;
  final Color background;
  final Color textColor;
  final VoidCallback onPressed;

  const WebProfileActionButton({
    super.key,
    required this.label,
    required this.background,
    required this.textColor,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 56,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[icon!, const SizedBox(width: 8)],
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: AppFonts.inriaSerif,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: textColor,
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
