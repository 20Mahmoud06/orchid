import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/app_keys.dart';
import '../../../core/storage/local_storage.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../view/widgets/wallet_provider.dart';
import 'wallet_state.dart';

class WalletCubit extends Cubit<WalletState> {
  WalletCubit(this._auth) : super(const WalletState()) {
    balanceController.addListener(_persistProviderData);
    walletIdController.addListener(_persistProviderData);
  }

  final AuthCubit _auth;
  final AppPrefs _prefs = AppPrefs.instance;

  final TextEditingController ownerNameController = TextEditingController(
    text: 'Mahmoud Safa',
  );
  final TextEditingController walletIdController = TextEditingController(
    text: '4821',
  );
  final TextEditingController balanceController = TextEditingController(
    text: '0',
  );

  bool _isSwitchingProvider = false;

  double get balance {
    final raw = balanceController.text.trim().replaceAll(',', '');
    return double.tryParse(raw) ?? 0;
  }

  /// Uses the signed-in user's phone number as the default wallet ID (only its
  /// last four digits are ever shown). Each provider keeps its own saved ID.
  /// Also restores the wallet picked last (kept in the app cache) so reopening
  /// the screen brings back the same provider together with its balance.
  Future<void> restoreWallet() async {
    final phone = _auth.userProfile?.phone ?? '';
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final savedProvider = await _prefs.getString(AppPrefKeys.walletProvider);
    if (isClosed) return;

    if (digits.length >= 4) {
      walletIdController.text = digits;
      emit(state.copyWith(defaultWalletId: digits));
    }

    if (savedProvider == null || savedProvider.isEmpty) return;
    if (!WalletProvider.providers.any((p) => p.name == savedProvider)) return;
    await changeProvider(WalletProvider.fromName(savedProvider));
  }

  /// Saves the outgoing wallet and loads the newly picked wallet's own balance
  /// and ID.
  Future<void> changeProvider(WalletProvider provider) async {
    final previous = state.selectedProvider;
    if (previous != null && previous.name != provider.name) {
      _saveProvider(previous);
    }

    final savedBalance = await _prefs.getString(
      AppPrefKeys.walletBalanceKey(provider.name),
    );
    final savedWalletId = await _prefs.getString(
      AppPrefKeys.walletIdKey(provider.name),
    );
    if (isClosed) return;

    _isSwitchingProvider = true;
    balanceController.text = savedBalance == null || savedBalance.isEmpty
        ? '0'
        : savedBalance;
    walletIdController.text = savedWalletId == null || savedWalletId.isEmpty
        ? state.defaultWalletId
        : savedWalletId;
    emit(state.copyWith(selectedProvider: provider));
    _isSwitchingProvider = false;
  }

  /// Persists the current balance and ID for the selected provider.
  void _persistProviderData() {
    final provider = state.selectedProvider;
    if (provider == null || _isSwitchingProvider) return;
    _saveProvider(provider);
  }

  void _saveProvider(WalletProvider provider) {
    _prefs.saveString(
      AppPrefKeys.walletBalanceKey(provider.name),
      balanceController.text,
    );
    _prefs.saveString(
      AppPrefKeys.walletIdKey(provider.name),
      walletIdController.text,
    );
    _prefs.saveString(AppPrefKeys.walletProvider, provider.name);
  }

  @override
  Future<void> close() {
    balanceController.removeListener(_persistProviderData);
    walletIdController.removeListener(_persistProviderData);
    ownerNameController.dispose();
    walletIdController.dispose();
    balanceController.dispose();
    return super.close();
  }
}
