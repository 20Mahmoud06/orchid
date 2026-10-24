import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orchid_admin/core/theme/app_theme.dart';
import 'package:orchid_admin/core/time/egypt_time.dart';
import 'package:orchid_admin/features/orders/domain/models/order_model.dart';
import 'package:orchid_admin/features/orders/presentation/widgets/orders_list_card.dart';

void main() {
  Order buildOrder() {
    return Order(
      id: 'order-1',
      orderCode: 'ORD-001',
      status: OrderStatus.pending,
      deliveryDate: DateTime(2026, 1, 15),
      orderTime: DateTime(2026, 1, 15, 10),
      deliveryAddress: 'Cairo',
      deliveryFee: 0,
      serviceFee: 0,
      total: 250,
      paymentMethod: 'CASH',
      userId: 'user-1',
      createdAt: DateTime(2026, 1, 15, 10),
      updatedAt: DateTime(2026, 1, 15, 10),
      items: const [],
      customerName: 'Mona',
    );
  }

  Widget buildCard({
    required List<Order> orders,
    required TextEditingController searchController,
    String periodLabel = 'Last 7 Days',
  }) {
    return MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: SingleChildScrollView(
          child: OrdersListCard(
            orders: orders,
            searchController: searchController,
            onSearchChanged: (_) {},
            statusFilter: null,
            onStatusFilterChanged: (_) {},
            selectedOrderId: null,
            onOrderSelected: (_) {},
            periodLabel: periodLabel,
          ),
        ),
      ),
    );
  }

  testWidgets('shows the selected period in the empty and footer states', (
    tester,
  ) async {
    final searchController = TextEditingController();
    addTearDown(searchController.dispose);
    await tester.binding.setSurfaceSize(const Size(500, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      buildCard(orders: const [], searchController: searchController),
    );
    await tester.pumpAndSettle();

    expect(find.text('No orders found for Last 7 Days.'), findsOneWidget);
    expect(find.text('0 orders in Last 7 Days'), findsOneWidget);
  });

  testWidgets('distinguishes filtered-out orders from an empty period', (
    tester,
  ) async {
    initTimeZones();
    final searchController = TextEditingController(text: 'missing');
    addTearDown(searchController.dispose);
    await tester.binding.setSurfaceSize(const Size(500, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      buildCard(orders: [buildOrder()], searchController: searchController),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('No orders match your search or status filter.'),
      findsOneWidget,
    );
    expect(find.text('1 order in Last 7 Days'), findsOneWidget);

    searchController.text = 'Mona';
    await tester.pumpWidget(
      buildCard(orders: [buildOrder()], searchController: searchController),
    );
    await tester.pumpAndSettle();

    expect(find.text('#ORD-001'), findsOneWidget);
    expect(
      find.text('No orders match your search or status filter.'),
      findsNothing,
    );
  });
}
