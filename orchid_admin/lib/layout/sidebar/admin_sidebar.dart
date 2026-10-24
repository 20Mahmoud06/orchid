import 'package:flutter/material.dart';

import '../../app/router/app_nav.dart';
import '../../app/router/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_text.dart';
import '../../features/auth/data/auth_service.dart';
import 'sidebar_item.dart';

class AdminSidebar extends StatelessWidget {
  const AdminSidebar({super.key, required this.currentRoute});

  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                CustomText(
                  text: 'ORCHID',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: AppColors.primary,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    CustomText(
                      text: 'ADMIN',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                        color: AppColors.textSecondary,
                        height: 1.1,
                      ),
                    ),
                    CustomText(
                      text: 'STUDIO',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                        color: AppColors.textSecondary,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          SidebarItem(
            currentRoute: currentRoute,
            label: 'Dashboard',
            icon: Icons.grid_view_rounded,
            route: AppRoutes.dashboard,
          ),
          SidebarItem(
            currentRoute: currentRoute,
            label: 'Products',
            icon: Icons.inventory_2_outlined,
            route: AppRoutes.products,
          ),
          SidebarItem(
            currentRoute: currentRoute,
            label: 'Orders',
            icon: Icons.local_shipping_outlined,
            route: AppRoutes.orders,
          ),
          SidebarItem(
            currentRoute: currentRoute,
            label: 'Inspiration',
            icon: Icons.auto_awesome_outlined,
            route: AppRoutes.inspiration,
          ),
          const Spacer(),
          SidebarItem(
            currentRoute: currentRoute,
            label: 'Logout',
            icon: Icons.logout_rounded,
            isDestructive: true,
            onTap: () async {
              await AuthService.signOut();
              if (context.mounted) {
                AppNav.replace(context, AppRoutes.login);
              }
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
