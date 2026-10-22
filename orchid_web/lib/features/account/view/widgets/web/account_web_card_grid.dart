import 'package:flutter/material.dart';

/// Lays out content cards in a responsive grid: two columns on wide screens,
/// a single stacked column on narrower ones. An odd last card spans the width.
class AccountWebCardGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double breakpoint;

  const AccountWebCardGrid({
    super.key,
    required this.children,
    this.spacing = 20,
    this.breakpoint = 640,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < breakpoint) {
          final stacked = <Widget>[];
          for (var i = 0; i < children.length; i++) {
            if (i > 0) stacked.add(SizedBox(height: spacing));
            stacked.add(children[i]);
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: stacked,
          );
        }

        final rows = <Widget>[];
        for (var i = 0; i < children.length; i += 2) {
          final hasRight = i + 1 < children.length;
          final isLast = i + 2 >= children.length;
          rows.add(
            Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : spacing),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: children[i]),
                  if (hasRight) ...[
                    SizedBox(width: spacing),
                    Expanded(child: children[i + 1]),
                  ],
                ],
              ),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: rows,
        );
      },
    );
  }
}
