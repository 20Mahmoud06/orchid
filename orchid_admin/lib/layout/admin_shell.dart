import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../core/responsive/breakpoints.dart';
import '../core/theme/app_colors.dart';
import 'header/admin_header.dart';
import 'sidebar/admin_sidebar.dart';

class AdminShell extends StatelessWidget {
  const AdminShell({
    super.key,
    required this.currentRoute,
    required this.child,
  });

  final String currentRoute;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        width: AppConstants.sidebarWidth,
        child: AdminSidebar(currentRoute: currentRoute),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool showSidebar = constraints.maxWidth >= Breakpoints.tablet;

          return Row(
            children: [
              if (showSidebar)
                SafeArea(
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      border:
                          Border(right: BorderSide(color: AppColors.border)),
                    ),
                    child: SizedBox(
                      width: AppConstants.sidebarWidth,
                      child: AdminSidebar(currentRoute: currentRoute),
                    ),
                  ),
                ),
              Expanded(
                child: Column(
                  children: [
                    const AdminHeader(),
                    Expanded(child: child),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
