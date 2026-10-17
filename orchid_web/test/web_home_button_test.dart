import 'package:ORCHID/core/app_keys.dart';
import 'package:ORCHID/core/router/app_routes.dart';
import 'package:ORCHID/shared/widgets/web_home_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_harness.dart';

void main() {
  setUp(() async {
    await TestHarness.boot();
    WebHomeRouteObserver.instance.reset();
  });

  tearDown(() {
    TestHarness.tearDown();
    WebHomeRouteObserver.instance.reset();
  });

  Future<void> pumpApp(WidgetTester tester, String initialRoute) async {
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        navigatorObservers: [WebHomeRouteObserver.instance],
        initialRoute: initialRoute,
        onGenerateRoute: (settings) => MaterialPageRoute<void>(
          settings: settings,
          builder: (context) =>
              Scaffold(body: Center(child: Text(settings.name ?? '/'))),
        ),
        builder: (context, child) => WebHomeButtonLayer(child: child!),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the home shortcut on inner screens and hides it on home', (
    tester,
  ) async {
    await pumpApp(tester, AppRoutes.cart);
    expect(find.byType(WebHomeButton), findsOneWidget);

    await tester.tap(find.byType(WebHomeButton));
    await tester.pumpAndSettle();

    expect(find.text(AppRoutes.mainNav), findsOneWidget);
    expect(find.byType(WebHomeButton), findsNothing);
    expect(navigatorKey.currentState!.canPop(), isFalse);
  });

  testWidgets('keeps the home shortcut hidden on the auth screens', (
    tester,
  ) async {
    await pumpApp(tester, AppRoutes.login);
    expect(find.byType(WebHomeButton), findsNothing);

    await pumpApp(tester, AppRoutes.signup);
    expect(find.byType(WebHomeButton), findsNothing);

    await pumpApp(tester, AppRoutes.forgotPassword);
    expect(find.byType(WebHomeButton), findsNothing);
  });

  testWidgets('keeps the home shortcut hidden while a dialog is open', (
    tester,
  ) async {
    await pumpApp(tester, AppRoutes.cart);
    expect(find.byType(WebHomeButton), findsOneWidget);

    showDialog<void>(
      context: tester.element(find.text(AppRoutes.cart)),
      builder: (context) => const AlertDialog(title: Text('dialog')),
    );
    await tester.pumpAndSettle();
    expect(find.byType(WebHomeButton), findsNothing);

    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(find.byType(WebHomeButton), findsOneWidget);
  });
}
