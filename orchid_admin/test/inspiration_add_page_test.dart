import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:orchid_admin/core/theme/app_theme.dart";
import "package:orchid_admin/features/inspiration/presentation/pages/add_inspiration_page.dart";
import "package:orchid_admin/features/products/data/repositories/products_repository.dart";
import "package:orchid_admin/features/products/domain/models/product_model.dart";

class _FakeProductsRepository extends ProductsRepository {
  _FakeProductsRepository(this.products);

  final List<Product> products;

  @override
  Future<List<Product>> getAllProducts() async => products;
}

Product _flower(String name, [double price = 30]) {
  return Product(
    id: "flower-${name.toLowerCase()}",
    name: name,
    price: price,
    type: ProductType.flower,
    isActive: true,
    imagePath: "",
    createdAt: DateTime(2026),
  );
}

Future<void> _pumpPage(WidgetTester tester, List<Product> products) async {
  await tester.binding.setSurfaceSize(const Size(1400, 900));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: AddInspirationPage(
          productsRepository: _FakeProductsRepository(products),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets("AddInspirationPage adds catalog flowers and hides description", (
    tester,
  ) async {
    await _pumpPage(tester, [
      _flower("Rose", 50),
      _flower("Tulip", 35),
      Product(
        id: "flower-lily",
        name: "Lily",
        price: 40,
        type: ProductType.flower,
        isActive: false,
        imagePath: "",
        createdAt: DateTime(2026),
      ),
      Product(
        id: "bouquet-1",
        name: "Ready Bouquet",
        price: 150,
        type: ProductType.readyBouquet,
        isActive: true,
        imagePath: "",
        createdAt: DateTime(2026),
      ),
    ]);

    expect(find.text("Add Inspiration"), findsWidgets);
    expect(find.text("Description"), findsNothing);
    expect(find.text("Rose"), findsOneWidget);
    expect(find.text("Tulip"), findsOneWidget);
    expect(find.text("Lily"), findsNothing);
    expect(find.text("Ready Bouquet"), findsNothing);

    await tester.tap(find.text("Tulip"));
    await tester.pumpAndSettle();

    expect(find.text("Selected Flowers"), findsOneWidget);
    expect(find.text("Tulip"), findsOneWidget);
    expect(find.text("EGP 35"), findsOneWidget);
    expect(find.text("Rose"), findsOneWidget);
    expect(find.text("1/7 kinds · 1/15 flowers"), findsOneWidget);
  });

  testWidgets("AddInspirationPage clamps quantities to 15 flowers", (
    tester,
  ) async {
    await _pumpPage(tester, [_flower("Rose"), _flower("Tulip")]);

    await tester.tap(find.text("Rose"));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).last, "20");
    await tester.pumpAndSettle();

    final quantityField = tester.widget<TextFormField>(
      find.byType(TextFormField).last,
    );
    expect(quantityField.controller?.text, "15");
    expect(find.text("1/7 kinds · 15/15 flowers"), findsOneWidget);
    expect(
      find.text("Your bouquet can contain up to 15 flowers."),
      findsOneWidget,
    );
    expect(find.text("Tulip"), findsNothing);
  });

  testWidgets("AddInspirationPage limits bouquets to 7 flower kinds", (
    tester,
  ) async {
    final names = [
      "Alstroemeria",
      "Carnation",
      "Daisy",
      "Jasmine",
      "Lily",
      "Orchid",
      "Rose",
      "Tulip",
    ];
    await _pumpPage(tester, [for (final name in names) _flower(name)]);

    for (final name in names.take(7)) {
      await tester.tap(find.text(name));
      await tester.pumpAndSettle();
    }

    expect(find.text("7/7 kinds · 7/15 flowers"), findsOneWidget);
    expect(
      find.text("You can add up to 7 different kinds of flowers."),
      findsOneWidget,
    );
    expect(find.text("Tulip"), findsNothing);
  });
}
