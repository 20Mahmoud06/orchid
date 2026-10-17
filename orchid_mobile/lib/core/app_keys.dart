import 'package:flutter/material.dart';

import 'storage/local_storage.dart';

/// Global navigator key so auth events (e.g. password recovery deep links) can
/// route the user even when there is no widget context available yet.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Global messenger key so auth errors can be surfaced from outside the
/// widget tree using the Orchid styling.
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

/// Route observer used to track route lifecycle events (e.g. re-activating the
/// splash screen after the recovery screen pushed on top of it gets popped).
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

/// Local preference keys persisted through [AppPrefs].
abstract class AppPrefKeys {
  static const String rememberMe = 'remember_me';
  static const String passwordRecoveryActive = 'password_recovery_active';
  static const String favoriteFlowerIds = 'favorite_flower_ids';
  static const String favoriteBouquetIds = 'favorite_bouquet_ids';
  static const String bouquetQuantities = 'bouquet_quantities';
  static const String cartItems = 'cart_items';
  static const String walletBalance = 'wallet_balance';
}