import 'package:flutter/material.dart';
import 'package:ORCHID/features/cart/view/screens/cart_screen.dart';
import 'package:ORCHID/features/favorites/view/screens/favorites_screen.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_bottom_navigation_bar.dart';
import '../../../../shared/widgets/web_top_nav_bar.dart';
import '../../../home/view/screens/home_screen.dart';
import 'profile_screen.dart';

/// Main navigation wrapper screen containing PageView and a responsive
/// top bar (web) or bottom bar (phones).
class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final useWebNav = constraints.maxWidth >= 768;
          final content = PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              const HomeScreen(),
              const FavoritesScreen(),
              const CartScreen(),
              ProfileScreen(
                onBackPressed: () {},
              ),
            ],
          );

          if (useWebNav) {
            return Column(
              children: [
                WebTopNavBar(
                  currentIndex: _currentIndex,
                  onItemSelected: _onBottomNavTapped,
                ),
                Expanded(child: content),
              ],
            );
          }

          return Scaffold(
            backgroundColor: AppColors.background,
            body: content,
            bottomNavigationBar: CustomBottomNavigationBar(
              currentIndex: _currentIndex,
              onItemSelected: _onBottomNavTapped,
            ),
          );
        },
      ),
    );
  }
}