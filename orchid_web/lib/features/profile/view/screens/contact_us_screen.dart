import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/contact_us_mobile_view.dart';
import '../widgets/web/contact_us_web_view.dart';

class ContactUsScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;

  const ContactUsScreen({super.key, this.onBackPressed});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const int _itemCount = 8;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Animation<double> _animFor(int index) {
    final start = (index / _itemCount) * 0.55;
    final end = (start + 0.45).clamp(0.0, 1.0);
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
  }

  Future<void> _launchUrl(
    String url, {
    LaunchMode mode = LaunchMode.externalApplication,
  }) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: mode);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Desktop-first web presentation (>= 768px): the same content laid out
        // in a centered reading column. Narrow viewports keep the untouched
        // Orchid mobile layout.
        if (constraints.maxWidth >= 768) {
          return ContactUsWebView(
            animationFor: _animFor,
            onLaunchUrl: _launchUrl,
          );
        }
        return ContactUsMobileView(
          onBackPressed: widget.onBackPressed,
          animationFor: _animFor,
          onLaunchUrl: _launchUrl,
        );
      },
    );
  }
}
