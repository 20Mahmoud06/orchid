import 'package:ORCHID/features/order/cubit/orders_cubit.dart';
import 'package:ORCHID/features/order/cubit/orders_state.dart';
import 'package:ORCHID/features/order/models/customer_order.dart';
import 'package:ORCHID/features/order/view/screens/order_history_screen.dart';
import 'package:ORCHID/features/order/view/widgets/order_history_card.dart';
import 'package:ORCHID/features/order/view/widgets/web/web_order_history_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_harness.dart';

/// Verifies the responsive Orders History page: the desktop-first web layout
/// (>= 768px) and the untouched mobile layout must both render without overflow
/// or exceptions at every breakpoint, and the web branch must show the order
/// list, tabs and empty state with the absolute-pixel widgets.
void main() {
  setUp(() async {
    await TestHarness.boot();
    OrdersCubit.instance.seed(const OrdersInitial());
  });

  tearDown(() {
    OrdersCubit.instance.seed(const OrdersInitial());
    TestHarness.tearDown();
  });

  CustomerOrder order({
    String id = 'o1',
    String status = 'PREPARING',
    String name = 'Rose Bouquet',
    int unitPrice = 240,
  }) {
    return CustomerOrder(
      id: id,
      orderCode: 'APL-CAB-20250612-8S9K',
      status: status,
      createdAt: DateTime(2025, 6, 12, 14, 30),
      total: unitPrice,
      items: [CustomerOrderItem(name: name, quantity: 1, unitPrice: unitPrice)],
      deliveryAddress: '12 Nile St, Cairo',
    );
  }

  Future<void> pumpAt(WidgetTester tester, Size size) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = size;
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) => MaterialApp(
          theme: ThemeData(fontFamily: 'Inria Serif'),
          home: child,
        ),
        child: const OrderHistoryScreen(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
  }

  /// The screen force-refreshes on open; with no signed-in user the load
  /// resolves to an empty list, so sample orders are seeded afterwards.
  ///
  /// Bounded pumps instead of `pumpAndSettle`: the order cards render
  /// `SkeletonImage`, whose shimmer keeps scheduling frames while the bundled
  /// picture resolves in the test environment, so nothing ever "settles".
  Future<void> seedOrders(
    WidgetTester tester,
    List<CustomerOrder> orders,
  ) async {
    await tester.pump(const Duration(seconds: 3));
    OrdersCubit.instance.seed(OrdersLoaded(orders));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  const breakpoints = <String, Size>{
    'mobile': Size(375, 812),
    'tablet': Size(768, 900),
    'laptop': Size(1024, 768),
    'wide': Size(1280, 800),
    'desktop': Size(1440, 900),
    'fullHd': Size(1920, 1080),
    'short': Size(1024, 520),
  };

  for (final entry in breakpoints.entries) {
    testWidgets('Order history renders without overflow (${entry.key})', (
      tester,
    ) async {
      await pumpAt(tester, entry.value);
      await seedOrders(tester, [order()]);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Order history uses the web layout and wording on desktop', (
    tester,
  ) async {
    await pumpAt(tester, const Size(1440, 900));
    await seedOrders(tester, [order()]);

    expect(find.byType(WebOrderHistoryHeader), findsOneWidget);
    expect(find.text('orders history'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Preparing'), findsOneWidget);
    expect(find.byType(WebOrderHistoryCard), findsOneWidget);
    expect(find.byType(OrderHistoryCard), findsNothing);
    expect(find.text('Rose Bouquet'), findsOneWidget);
    expect(find.text('#APL-CAB-20250612-8S9K'), findsOneWidget);
    expect(find.text('12 Jun 2025'), findsOneWidget);
    expect(find.text('240 EGP'), findsOneWidget);
    expect(find.text('PREPARING'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Order history filters by the selected tab on desktop', (
    tester,
  ) async {
    await pumpAt(tester, const Size(1440, 900));
    await seedOrders(tester, [
      order(),
      order(id: 'o2', status: 'COMPLETED', name: 'Tulip Box', unitPrice: 300),
    ]);

    expect(find.byType(WebOrderHistoryCard), findsNWidgets(2));

    await tester.tap(find.text('Completed'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(WebOrderHistoryCard), findsOneWidget);
    expect(find.text('Tulip Box'), findsOneWidget);
    expect(find.text('Rose Bouquet'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Order history keeps the mobile layout below the breakpoint', (
    tester,
  ) async {
    await pumpAt(tester, const Size(375, 812));
    await seedOrders(tester, [order()]);

    expect(find.byType(WebOrderHistoryHeader), findsNothing);
    expect(find.byType(OrderHistoryCard), findsOneWidget);
    expect(find.text('orders history'), findsOneWidget);
    expect(find.text('Rose Bouquet'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Empty order history shows the web empty state on desktop', (
    tester,
  ) async {
    await pumpAt(tester, const Size(1440, 900));
    await tester.pump(const Duration(seconds: 3));

    expect(find.byType(WebOrderEmptyState), findsOneWidget);
    expect(find.text('no orders yet'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
