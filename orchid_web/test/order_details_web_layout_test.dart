import 'package:ORCHID/features/order/models/customer_order.dart';
import 'package:ORCHID/features/order/view/screens/order_details_screen.dart';
import 'package:ORCHID/features/order/view/widgets/web/web_order_details_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_harness.dart';

/// Verifies the responsive Order Details page: the desktop-first web layout
/// (>= 768px) and the untouched mobile layout must both render without overflow
/// or exceptions at every breakpoint.
void main() {
  setUp(() async {
    await TestHarness.boot();
  });

  tearDown(TestHarness.tearDown);

  final sampleOrder = CustomerOrder(
    id: 'o1',
    orderCode: 'APL-CAB-20250612-8S9K',
    status: 'PREPARING',
    createdAt: DateTime(2025, 6, 12, 14, 30),
    total: 480,
    items: const [
      CustomerOrderItem(
        name: 'Rose Bouquet',
        quantity: 2,
        unitPrice: 100,
        description: '20 red roses',
      ),
      CustomerOrderItem(
        name: 'Tulip Box',
        quantity: 1,
        unitPrice: 280,
        message: 'Happy Birthday',
      ),
    ],
    deliveryAddress: '12 Nile St, Cairo',
    message: 'Happy Birthday',
    notes: 'Call on arrival',
  );

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
        child: OrderDetailsScreen(order: sampleOrder),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
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
    testWidgets('Order details renders without overflow (${entry.key})', (
      tester,
    ) async {
      await pumpAt(tester, entry.value);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Order details uses the web layout and wording on desktop', (
    tester,
  ) async {
    await pumpAt(tester, const Size(1440, 900));

    expect(find.byType(WebOrderDetailsHeader), findsOneWidget);
    expect(find.text('order details'), findsOneWidget);
    expect(find.byType(WebOrderStatusCard), findsOneWidget);
    expect(find.byType(WebOrderItemsCard), findsOneWidget);
    expect(find.byType(WebOrderDeliveryCard), findsOneWidget);
    expect(find.text('#APL-CAB-20250612-8S9K'), findsOneWidget);
    expect(find.text('PREPARING'), findsOneWidget);
    expect(find.text('placed on 12 Jun 2025, 2:30 PM'), findsOneWidget);
    expect(find.text('total'), findsOneWidget);
    expect(find.text('480 EGP'), findsOneWidget);
    expect(find.text('items (3)'), findsOneWidget);
    expect(find.text('Rose Bouquet'), findsOneWidget);
    expect(find.text('2 × 100 EGP'), findsOneWidget);
    expect(find.text('200 EGP'), findsOneWidget);
    expect(find.text('20 red roses'), findsOneWidget);
    // The gift message appears both on the item line and in the delivery card.
    expect(find.text('Happy Birthday'), findsNWidgets(2));
    expect(find.text('12 Nile St, Cairo'), findsOneWidget);
    expect(find.text('Call on arrival'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Order details keeps the mobile layout below the breakpoint', (
    tester,
  ) async {
    await pumpAt(tester, const Size(375, 812));

    expect(find.byType(WebOrderDetailsHeader), findsNothing);
    expect(find.byType(WebOrderItemsCard), findsNothing);
    expect(find.text('order details'), findsOneWidget);
    expect(find.text('items (3)'), findsOneWidget);
    expect(find.text('Rose Bouquet'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
