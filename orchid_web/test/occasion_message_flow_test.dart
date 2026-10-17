import 'package:ORCHID/core/app_keys.dart';
import 'package:ORCHID/core/router/app_router.dart';
import 'package:ORCHID/core/router/app_routes.dart';
import 'package:ORCHID/features/choose_bouquets/view/screens/choose_bouquets_screen.dart';
import 'package:ORCHID/features/choose_flowers/view/screens/choose_flowers_screen.dart';
import 'package:ORCHID/features/home/view/screens/home_screen.dart';
import 'package:ORCHID/shared/widgets/web_home_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_harness.dart';

/// Home 'Shop by occasion' message flow on the web layout: tapping an
/// occasion shows the message input, Send opens the bouquet options dialog,
/// and both dialog actions navigate to their screen.
void main() {
  setUp(() async {
    await TestHarness.boot();
  });

  tearDown(TestHarness.tearDown);

  Future<void> pumpAppShell(WidgetTester tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1440, 900);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) => GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(context).copyWith(size: const Size(375, 812)),
              child: ColoredBox(
                color: const Color(0xFFFDF8F6),
                child: SizedBox.expand(
                  child: MaterialApp(
                    debugShowCheckedModeBanner: false,
                    navigatorKey: navigatorKey,
                    scaffoldMessengerKey: scaffoldMessengerKey,
                    navigatorObservers: [routeObserver],
                    theme: ThemeData(fontFamily: 'Inria Serif'),
                    onGenerateRoute: AppRouter.generateRoute,
                    onGenerateInitialRoutes: (initialRoute) => [
                      AppRouter.generateRoute(
                        const RouteSettings(name: AppRoutes.mainNav),
                      ),
                    ],
                    builder: (context, child) =>
                        WebHomeButtonLayer(child: child!),
                  ),
                ),
              ),
            ),
          ),
        ),
        child: null,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('occasion Send opens dialog and BUY EXISTING navigates', (
    tester,
  ) async {
    await pumpAppShell(tester);
    expect(find.byType(HomeScreen), findsOneWidget);

    await tester.tap(find.text('Birthday'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(TextField), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Happy Birthday Mom');
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('Send'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Your Message Is Ready'), findsOneWidget);

    await tester.tap(find.text('BUY EXISTING BOUQUET'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(ChooseBouquetScreen), findsOneWidget);
  });

  testWidgets('Enter in the message field opens the dialog too', (
    tester,
  ) async {
    await pumpAppShell(tester);

    await tester.tap(find.text('Anniversary'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.enterText(find.byType(TextField), 'With love');
    await tester.pump(const Duration(milliseconds: 300));

    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Your Message Is Ready'), findsOneWidget);

    await tester.tap(find.text('CREATE MY BOUQUET'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(ChooseFlowersScreen), findsOneWidget);
  });

  testWidgets('Send without typing still opens the dialog', (tester) async {
    await pumpAppShell(tester);

    await tester.tap(find.text('Graduation'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Send'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Your Message Is Ready'), findsOneWidget);
  });
}
