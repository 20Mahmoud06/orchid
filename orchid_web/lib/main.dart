import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'core/app_keys.dart';
import 'features/bouquet/cubit/bouquet_cubit.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_skeleton.dart';
import 'core/constants/app_strings.dart';
import 'features/favorites/cubit/favorites_cubit.dart';
import 'core/router/app_router.dart';
import 'core/router/app_routes.dart';
import 'core/theme/app_page_transitions.dart';
import 'features/auth/recovery_link_handler.dart';
import 'features/cart/cubit/cart_cubit.dart';
import 'shared/widgets/web_home_button.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://krfzptcxdjzgylqwiulv.supabase.co',
    publishableKey: 'sb_publishable_zihRKfJx8aa2Ga8E-ayqvA_3E9j_3ED',
  );
  // App-lifetime deep-link listener: password recovery links can arrive at any
  // time, not only during startup.
  RecoveryLinkHandler.instance.init();
  // Restore the favorites, bouquet selections and cart contents that were
  // saved on this device during previous runs.
  await FavoritesCubit.instance.init();
  await BouquetCubit.instance.init();
  await CartCubit.instance.init();
  runApp(const OrchidApp());
}

class OrchidApp extends StatelessWidget {
  const OrchidApp({super.key});

  @override
  Widget build(BuildContext context) {
    final app = ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: MaterialApp(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            navigatorKey: navigatorKey,
            scaffoldMessengerKey: scaffoldMessengerKey,
            navigatorObservers: [routeObserver, WebHomeRouteObserver.instance],
            theme: ThemeData(
              fontFamily: 'Inria Serif',
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primary,
                primary: AppColors.primary,
                error: AppColors.error,
                surface: AppColors.background,
              ),
              scaffoldBackgroundColor: AppColors.background,
              // Web: swap page content with a soft cross-fade instead of the
              // default slide/zoom.
              pageTransitionsTheme: const PageTransitionsTheme(
                builders: {
                  TargetPlatform.android: AppPageTransitionsBuilder(),
                  TargetPlatform.iOS: AppPageTransitionsBuilder(),
                  TargetPlatform.windows: AppPageTransitionsBuilder(),
                  TargetPlatform.macOS: AppPageTransitionsBuilder(),
                  TargetPlatform.linux: AppPageTransitionsBuilder(),
                  TargetPlatform.fuchsia: AppPageTransitionsBuilder(),
                },
              ),
            ),
            initialRoute: AppRoutes.splash,
            onGenerateRoute: AppRouter.generateRoute,
            builder: (context, child) {
              final content = SkeletonizerConfig(
                data: AppSkeleton.configData,
                child: child!,
              );
              // Web: float a home shortcut above every screen so shoppers can
              // always return to the storefront even when the browser's back
              // button misbehaves.
              return WebHomeButtonLayer(child: content);
            },
          ),
        );
      },
    );

    // Web: pin the perceived screen size to the design size so `flutter_screenutil`
    // keeps a 1:1 scale (no gigantic buttons/text on large monitors), but let the
    // app fill the full browser width. Individual screens decide their own layout
    // below, e.g. auth screens center a card on the full-width background.
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(size: const Size(375, 812)),
      child: ColoredBox(
        color: AppColors.background,
        child: SizedBox.expand(child: app),
      ),
    );
  }
}
