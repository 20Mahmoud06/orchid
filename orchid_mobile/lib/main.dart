import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'features/auth/recovery_link_handler.dart';
import 'features/cart/cubit/cart_cubit.dart';
import 'features/offline/view/screens/offline_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://krfzptcxdjzgylqwiulv.supabase.co',
    publishableKey: 'sb_publishable_zihRKfJx8aa2Ga8E-ayqvA_3E9j_3ED',
  );
  // App-lifetime deep-link listener: password recovery links can arrive at any
  // time, not only while the splash screen is visible.
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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return ScreenUtilInit(
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
            navigatorObservers: [routeObserver],
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
            ),
            initialRoute: AppRoutes.splash,
            onGenerateRoute: AppRouter.generateRoute,
            builder: (context, child) {
              return SkeletonizerConfig(
                data: AppSkeleton.configData,
                child: OfflineWrapper(child: child!),
              );
            },
          ),
        );
      },
    );
  }
}