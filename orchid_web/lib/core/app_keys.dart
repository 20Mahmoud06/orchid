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

  /// Wallet balance for a single provider (e.g. `wallet_balance_vodafone_cash`),
  /// so every digital wallet keeps its own money.
  static String walletBalanceKey(String providerName) =>
      'wallet_balance_${_slug(providerName)}';

  /// Wallet ID (number) for a single provider, so every digital wallet keeps
  /// its own number.
  static String walletIdKey(String providerName) =>
      'wallet_id_${_slug(providerName)}';

  /// Name of the wallet provider picked last, so reopening the app (or a
  /// browser refresh) restores the same wallet and its saved balance.
  static const String walletProvider = 'wallet_provider';

  static String _slug(String value) =>
      value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
}
