import 'package:ORCHID/features/my_bank_cart/view/screens/my_bank_cart_screen.dart';
import 'package:ORCHID/features/my_wallet/view/screens/my_wallet_screen.dart';
import 'package:flutter/material.dart';
import '../../features/auth/view/screens/forgot_password_screen.dart';
import '../../features/auth/view/screens/login_screen.dart';
import '../../features/auth/view/screens/sign_up_screen.dart';
import '../../features/auth/view/screens/splash_screen.dart';
import '../../features/payment/view/screens/payment_pending_screen.dart';
import '../../features/payment/view/screens/payment_screen.dart';
import '../../features/profile/view/screens/complete_profile_screen.dart';
import '../../features/profile/view/screens/contact_us_screen.dart';
import '../../features/profile/view/screens/edit_profile_screen.dart';
import '../../features/profile/view/screens/main_navigation_screen.dart';
import '../../features/account/view/screens/privacy_policy_screen.dart';
import '../../features/account/view/screens/terms_conditions_screen.dart';
import '../../features/account/view/screens/about_screen.dart';
import '../../features/choose_flowers/view/screens/choose_flowers_screen.dart';
import '../../features/choose_bouquets/view/screens/choose_bouquets_screen.dart';
import '../../features/cart/view/screens/cart_screen.dart';
import '../../features/favorites/view/screens/favorites_screen.dart';
import '../../features/add_message/view/screens/add_message_screen.dart';
import '../../features/delivery/view/screens/delivery_details_screen.dart';
import '../../features/confirm/view/screens/confirm_screen.dart';
import '../../features/order/view/screens/order_history_screen.dart';
import '../../features/order/view/screens/order_summary_screen.dart';
import '../../features/order/view/screens/order_details_screen.dart';
import '../../features/order/models/customer_order.dart';
import '../../features/inspiration/view/screens/inspiration_screen.dart';
import '../../features/bouquet/view/screens/view_bouquet_screen.dart';
import '../../features/inspiration/models/inspiration_item.dart';
import 'app_routes.dart';

/// Centralized route generator for Orchid application navigation.
abstract class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (context) => LoginScreen(
            onNavigateToSignup: () => _navigateToSignUp(context),
            onNavigateToForgotPassword: () =>
                _navigateToForgotPassword(context),
          ),
        );

      case AppRoutes.signup:
        return MaterialPageRoute(
          builder: (context) => SignUpScreen(
            onNavigateToLogin: () => _navigateToLogin(context),
            onBackPressed: () => Navigator.maybePop(context),
          ),
        );

      case AppRoutes.completeProfile:
        final completeProfileArgs = settings.arguments;
        final fromSignUp = completeProfileArgs is CompleteProfileArgs &&
            completeProfileArgs.fromSignUp;
        return MaterialPageRoute(
          builder: (context) =>
              CompleteProfileScreen(fromSignUp: fromSignUp),
        );

      case AppRoutes.forgotPassword:
        final forgotPasswordArgs = settings.arguments;
        final recoveryMode = forgotPasswordArgs is ForgotPasswordScreenArgs &&
            forgotPasswordArgs.recoveryMode;
        return MaterialPageRoute(
          builder: (context) => ForgotPasswordScreen(
            recoveryMode: recoveryMode,
            onBackPressed: () => Navigator.maybePop(context),
          ),
        );

      case AppRoutes.mainNav:
        return MaterialPageRoute(
          builder: (context) => const MainNavigationScreen(),
        );

      case AppRoutes.profile:
        return MaterialPageRoute(
          builder: (context) => const MainNavigationScreen(initialIndex: 3),
        );

      case AppRoutes.editProfile:
        return MaterialPageRoute(
          builder: (context) => EditProfileScreen(
            onBackPressed: () => Navigator.maybePop(context),
          ),
        );

      case AppRoutes.contactUs:
        return MaterialPageRoute(
          builder: (context) =>
              ContactUsScreen(onBackPressed: () => Navigator.maybePop(context)),
        );

      case AppRoutes.chooseFlowers:
        return MaterialPageRoute(
          builder: (context) => ChooseFlowersScreen(
            onBackPressed: () => Navigator.maybePop(context),
          ),
        );

      case AppRoutes.myCard:
        return MaterialPageRoute(
          builder: (context) =>
              MyBankCartScreen(onBackPressed: () => Navigator.maybePop(context)),
        );

      case AppRoutes.chooseBouquets:
        return MaterialPageRoute(
          builder: (context) => ChooseBouquetScreen(
            onBackPressed: () => Navigator.maybePop(context),
          ),
        );

      case AppRoutes.cart:
        return MaterialPageRoute(
          builder: (context) =>
              CartScreen(onBackPressed: () => Navigator.maybePop(context)),
        );

      case AppRoutes.favorites:
        return MaterialPageRoute(
          builder: (context) =>
              FavoritesScreen(onBackPressed: () => Navigator.maybePop(context)),
        );

      case AppRoutes.addMessage:
        return MaterialPageRoute(
          builder: (context) => AddMessageScreen(
            onBackPressed: () => Navigator.maybePop(context),
            cartItemId:
                settings.arguments is String ? settings.arguments as String : null,
          ),
        );

      case AppRoutes.deliveryDetails:
        return MaterialPageRoute(
          builder: (context) => DeliveryDetailsScreen(
            onBackPressed: () => Navigator.maybePop(context),
          ),
        );

      case AppRoutes.orderSummary:
        return MaterialPageRoute(
          builder: (context) => OrderSummaryScreen(
            onBackPressed: () => Navigator.maybePop(context),
          ),
        );

      case AppRoutes.orderHistory:
        return MaterialPageRoute(
          builder: (context) => OrderHistoryScreen(
            onBackPressed: () => Navigator.maybePop(context),
          ),
        );

      case AppRoutes.orderDetails:
        final orderArgs = settings.arguments;
        if (orderArgs is CustomerOrder) {
          return MaterialPageRoute(
            builder: (_) => OrderDetailsScreen(order: orderArgs),
          );
        }
        return MaterialPageRoute(
          builder: (context) => OrderHistoryScreen(
            onBackPressed: () => Navigator.maybePop(context),
          ),
        );

      case AppRoutes.inspiration:
        return MaterialPageRoute(
          builder: (context) => InspirationScreen(
            onBackPressed: () => Navigator.maybePop(context),
          ),
        );

      case AppRoutes.viewBouquet:
        final args = settings.arguments;
        return MaterialPageRoute(
          builder: (context) => ViewBouquetScreen(
            onBackPressed: () => Navigator.maybePop(context),
            bouquet: args is InspirationItem ? args : null,
          ),
        );

      case AppRoutes.myWallet:
        return MaterialPageRoute(
          builder: (context) => MyWalletScreen(
            onBackPressed: () => Navigator.maybePop(context),
          ),
        );

      case AppRoutes.payment:
        return MaterialPageRoute(
          builder: (context) =>
              PaymentScreen(onBackPressed: () => Navigator.maybePop(context)),
        );

      case AppRoutes.paymentPending:
        final paymentArgs = settings.arguments;
        if (paymentArgs is PaymentPendingArgs) {
          return MaterialPageRoute(
            builder: (_) => PaymentPendingScreen(args: paymentArgs),
          );
        }
        return MaterialPageRoute(
          builder: (context) =>
              PaymentScreen(onBackPressed: () => Navigator.maybePop(context)),
        );

      case AppRoutes.confirm:
        return MaterialPageRoute(builder: (_) => const ConfirmScreen());

      case AppRoutes.privacyPolicy:
        return MaterialPageRoute(
          builder: (context) =>
              PrivacyPolicyScreen(onBackPressed: () => Navigator.maybePop(context)),
        );

      case AppRoutes.termsConditions:
        return MaterialPageRoute(
          builder: (context) =>
              TermsConditionsScreen(onBackPressed: () => Navigator.maybePop(context)),
        );

      case AppRoutes.aboutApp:
        return MaterialPageRoute(
          builder: (context) =>
              AboutScreen(onBackPressed: () => Navigator.maybePop(context)),
        );

      default:
        return MaterialPageRoute(
          builder: (context) => const MainNavigationScreen(initialIndex: 0),
        );
    }
  }

  static void _navigateToSignUp(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.signup);
  }

  static void _navigateToLogin(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  static void _navigateToForgotPassword(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.forgotPassword);
  }
}