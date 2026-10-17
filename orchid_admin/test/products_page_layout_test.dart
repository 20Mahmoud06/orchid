import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:orchid_admin/core/theme/app_theme.dart";
import "package:orchid_admin/features/products/presentation/pages/products_page.dart";

void main() {
  testWidgets("ProductsPage builds without layout exception", (tester) async {
    final errors = <FlutterErrorDetails>[];
    final old = FlutterError.onError;
    FlutterError.onError = (details) => errors.add(details);

    await tester.binding.setSurfaceSize(const Size(1400, 900));
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const ProductsPage(),
      ),
    );
    await tester.pumpAndSettle();

    FlutterError.onError = old;
    expect(errors, isEmpty, reason: errors.map((e) => e.exceptionAsString()).join("\\n"));
    expect(find.text("Products"), findsWidgets);
  });
}
