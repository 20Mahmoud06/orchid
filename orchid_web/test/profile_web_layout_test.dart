import 'package:ORCHID/features/profile/view/screens/edit_profile_screen.dart';
import 'package:ORCHID/features/profile/view/screens/profile_screen.dart';
import 'package:ORCHID/features/profile/view/widgets/web/web_profile_avatars.dart';
import 'package:ORCHID/features/profile/view/widgets/web/web_profile_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_harness.dart';

/// Verifies the responsive Profile page: the desktop-first web layout
/// (>= 768px) and the untouched mobile layout must both render without overflow
/// or exceptions at every breakpoint.
void main() {
  setUp(() async {
    await TestHarness.boot();
  });

  tearDown(TestHarness.tearDown);

  Future<void> pumpAt(WidgetTester tester, Size size, Widget child) async {
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
        child: child,
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
    testWidgets('Profile renders without overflow (${entry.key})', (
      tester,
    ) async {
      await pumpAt(tester, entry.value, const ProfileScreen());
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Profile uses the desktop dashboard wording on wide screens', (
    tester,
  ) async {
    await pumpAt(tester, const Size(1440, 900), const ProfileScreen());
    expect(find.text('My Profile'), findsOneWidget);
    expect(find.text('Log Out'), findsOneWidget);
    expect(find.text('Delete Account'), findsOneWidget);
    expect(find.text('Account'), findsNothing);
    expect(find.text('Privacy Policy'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Profile keeps the mobile layout below the breakpoint', (
    tester,
  ) async {
    await pumpAt(tester, const Size(375, 812), const ProfileScreen());
    expect(find.text('My Profile'), findsOneWidget);
    expect(find.text('Log Out'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final entry in breakpoints.entries) {
    testWidgets('Edit Profile renders without overflow (${entry.key})', (
      tester,
    ) async {
      await pumpAt(tester, entry.value, const EditProfileScreen());
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Edit Profile uses the desktop panel wording on wide screens', (
    tester,
  ) async {
    await pumpAt(tester, const Size(1440, 900), const EditProfileScreen());
    expect(find.text('Edit Profile'), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Phone Number'), findsOneWidget);
    expect(find.text('Whatsapp Number'), findsOneWidget);
    expect(find.text('Delivery Address'), findsOneWidget);
    expect(find.text('Save Changes'), findsOneWidget);
    expect(find.byType(WebEditProfileAvatar), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Log Out opens the desktop dialog on wide screens', (
    tester,
  ) async {
    await pumpAt(tester, const Size(1440, 900), const ProfileScreen());
    await tester.tap(find.text('Log Out'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(WebLogoutDialog), findsOneWidget);
    expect(find.text('are you sure you want to log out?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(WebLogoutDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Delete Account opens the desktop dialog on wide screens', (
    tester,
  ) async {
    await pumpAt(tester, const Size(1440, 900), const ProfileScreen());
    await tester.tap(find.text('Delete Account'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(WebDeleteAccountDialog), findsOneWidget);
    expect(
      find.text(
        'are you sure you want to permanently delete '
        'your account?\nthis action cannot be undone.',
      ),
      findsOneWidget,
    );
    expect(find.text('Delete'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(WebDeleteAccountDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Log Out dialog stays desktop-sized with a pinned MediaQuery', (
    tester,
  ) async {
    // Reproduces the real web build: `MediaQuery.size` is pinned to the phone
    // design size while the underlying FlutterView keeps the browser size.
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1440, 900);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(375, 812)),
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) => MaterialApp(
            theme: ThemeData(fontFamily: 'Inria Serif'),
            home: const ProfileScreen(),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    await tester.tap(find.text('Log Out'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(WebLogoutDialog), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Profile dialogs keep the mobile layout below the breakpoint', (
    tester,
  ) async {
    await pumpAt(tester, const Size(375, 812), const ProfileScreen());
    await tester.tap(find.text('Log Out'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(WebLogoutDialog), findsNothing);
    expect(find.text('are you sure you want to log out?'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
