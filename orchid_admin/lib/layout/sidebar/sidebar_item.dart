import 'package:flutter/material.dart';

import '../../app/router/app_nav.dart';
import '../../core/theme/app_colors.dart';

class SidebarItem extends StatelessWidget {
  const SidebarItem({
    super.key,
    required this.currentRoute,
    required this.label,
    required this.icon,
    this.route,
    this.onTap,
    this.isDestructive = false,
  });

  final String currentRoute;
  final String label;
  final IconData icon;
  final String? route;
  final VoidCallback? onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final isActive = !isDestructive &&
        route != null &&
        (currentRoute == route ||
            (route != '/' && currentRoute.startsWith('$route/')));

    final Color foreground = isDestructive
        ? AppColors.error
        : isActive
            ? AppColors.primary
            : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Material(
        color: isActive ? AppColors.softLime : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: () {
            if (onTap != null) {
              onTap!();
              return;
            }
            if (route == null) return;

            if (isActive) {
              final scaffold = Scaffold.maybeOf(context);
              if (scaffold?.isDrawerOpen ?? false) {
                Navigator.of(context).pop();
              }
              return;
            }

            final scaffold = Scaffold.maybeOf(context);
            final wasOpen = scaffold?.isDrawerOpen ?? false;
            if (isDestructive) {
              AppNav.replace(context, route!);
            } else {
              AppNav.go(context, route!);
            }
            if (wasOpen && context.mounted) {
              Navigator.of(context).pop();
            }
          },
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(icon, size: 20, color: foreground),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      color: foreground,
                    ),
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
