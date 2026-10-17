import 'package:ORCHID/core/constants/app_skeleton.dart';
import 'package:ORCHID/shared/widgets/skeleton_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skeletonizer/skeletonizer.dart';

Widget _host(Widget child, {bool inScrollView = false}) {
  return MaterialApp(
    home: Scaffold(
      backgroundColor: Colors.white,
      body: inScrollView
          ? SingleChildScrollView(child: Column(children: [child]))
          : Center(child: child),
    ),
  );
}

void main() {
  // A bundled asset that exists, so the success path is exercised for real.
  const imagePath = 'assets/images/placeholder_profile.png';
  const missingPath = 'assets/images/does_not_exist.png';

  final bones = find.byWidgetPredicate((widget) => widget is Bone);

  // NOTE: asset loading needs real I/O, which the fake-async test zone only
  // services for the first `testWidgets` in a file. That is why this end-to-end
  // loading test must stay first; everything below is purely structural.
  testWidgets('shows a shimmering bone, then swaps to the real image',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SkeletonizerConfig(
            data: AppSkeleton.configData,
            child: const SizedBox(
              width: 200,
              height: 150,
              child: SkeletonImage(path: imagePath),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(SkeletonImage), findsOneWidget);
    expect(bones, findsOneWidget);
    expect(find.byType(Image), findsNothing);

    for (var i = 0; i < 10 && find.byType(Image).evaluate().isEmpty; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump(const Duration(milliseconds: 120));
    }

    expect(tester.takeException(), isNull);
    expect(bones, findsNothing);
    expect(find.byType(Image), findsOneWidget);
    expect(tester.widget<Image>(find.byType(Image)).image, isA<AssetImage>());

    // A dependency change re-runs the resolve step; a cached picture must not
    // send the already visible image back to the shimmering bone.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MediaQuery(
            data: const MediaQueryData(size: Size(500, 900)),
            child: SkeletonizerConfig(
              data: AppSkeleton.configData,
              child: const SizedBox(
                width: 200,
                height: 150,
                child: SkeletonImage(path: imagePath),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.takeException(), isNull);
    expect(bones, findsNothing);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('falls back without shimmering when there is no picture path',
      (tester) async {
    await tester.pumpWidget(
      _host(
        const SizedBox(
          width: 120,
          height: 90,
          child: SkeletonImage(path: '   ', errorWidget: SkeletonFallbackBox()),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));

    expect(bones, findsNothing);
    expect(find.byType(Image), findsNothing);
    expect(tester.getSize(find.byType(SkeletonFallbackBox)), const Size(120, 90));
    expect(tester.takeException(), isNull);
  });

  testWidgets('paints a plain colored box by default when there is no picture',
      (tester) async {
    await tester.pumpWidget(
      _host(
        const SizedBox(
          width: 120,
          height: 90,
          child: SkeletonImage(path: ''),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));

    final box = tester.widget<Container>(
      find.descendant(
        of: find.byType(SkeletonImage),
        matching: find.byType(Container),
      ).first,
    );
    expect(box.constraints?.maxWidth, 120);
    expect(box.constraints?.maxHeight, 90);
    expect(box.color, AppSkeleton.fallbackColor);
    expect(tester.takeException(), isNull);
  });

  testWidgets('never requests an infinite size inside a scroll view',
      (tester) async {
    await tester.pumpWidget(
      _host(
        const SkeletonImage(
          path: imagePath,
          width: 240,
          placeholderSize: Size(240, 240),
        ),
        inScrollView: true,
      ),
    );

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(SkeletonImage)).width, 240);
  });

  testWidgets('clips the bone with the requested radius', (tester) async {
    await tester.pumpWidget(
      _host(
        const SizedBox(
          width: 120,
          height: 90,
          child: SkeletonImage(
            path: missingPath,
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
    );

    expect(find.byType(ClipRRect), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fills a bounded parent it was not given a size for',
      (tester) async {
    await tester.pumpWidget(
      _host(
        const SizedBox(
          width: 120,
          height: 90,
          child: SkeletonImage(path: missingPath),
        ),
      ),
    );

    expect(tester.getSize(find.byType(SkeletonImage)), const Size(120, 90));
    expect(tester.takeException(), isNull);
  });

  testWidgets('fallback box fills its parent and never goes infinite',
      (tester) async {
    await tester.pumpWidget(
      _host(
        const SizedBox(
          width: 120,
          height: 90,
          child: SkeletonFallbackBox(),
        ),
      ),
    );

    expect(
      tester.getSize(find.byType(SkeletonFallbackBox)),
      const Size(120, 90),
    );

    await tester.pumpWidget(_host(const SkeletonFallbackBox(), inScrollView: true));
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows the bone again when the picture path changes',
      (tester) async {
    await tester.pumpWidget(
      _host(
        const SizedBox(
          width: 120,
          height: 90,
          child: SkeletonImage(path: missingPath),
        ),
      ),
    );

    expect(bones, findsOneWidget);

    await tester.pumpWidget(
      _host(
        const SizedBox(
          width: 120,
          height: 90,
          child: SkeletonImage(path: 'assets/images/circle_flower.png'),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(bones, findsOneWidget);
  });

  testWidgets('keeps a cached picture visible across dependency changes',
      (tester) async {
    await tester.pumpWidget(
      _host(
        const SizedBox(
          width: 120,
          height: 90,
          child: SkeletonImage(path: imagePath),
        ),
      ),
    );

    // `imagePath` was resolved by the first test, so it comes back from the
    // image cache synchronously and must never flash the bone.
    expect(bones, findsNothing);
    expect(find.byType(Image), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MediaQuery(
            data: const MediaQueryData(size: Size(500, 900)),
            child: SizedBox(
              width: 120,
              height: 90,
              child: SkeletonImage(path: imagePath),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.takeException(), isNull);
    expect(bones, findsNothing);
    expect(find.byType(Image), findsOneWidget);
  });
}