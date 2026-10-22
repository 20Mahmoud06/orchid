import 'package:flutter/material.dart';

import 'package:ORCHID/core/constants/app_colors.dart';
import 'package:ORCHID/core/constants/app_fonts.dart';

/// Two-column field grid that collapses to a single column on narrow cards.
class WebProfileInfoGrid extends StatelessWidget {
  final List<Widget> children;

  const WebProfileInfoGrid({super.key, required this.children});

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

class WebProfileInfoField extends StatelessWidget {
  final String label;
  final String value;
  final bool showArrow;

  const WebProfileInfoField({
    super.key,
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
