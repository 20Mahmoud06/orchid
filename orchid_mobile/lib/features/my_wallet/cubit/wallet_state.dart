import 'package:equatable/equatable.dart';

import '../view/widgets/wallet_provider.dart';

const Object _unset = Object();

class WalletState extends Equatable {
  const WalletState({this.selectedProvider, this.defaultWalletId = '4821'});

  final WalletProvider? selectedProvider;
  final String defaultWalletId;

  WalletState copyWith({
    Object? selectedProvider = _unset,
    String? defaultWalletId,
  }) {
    return WalletState(
      selectedProvider: identical(selectedProvider, _unset)
          ? this.selectedProvider
          : selectedProvider as WalletProvider?,
      defaultWalletId: defaultWalletId ?? this.defaultWalletId,
    );
  }

  @override
  List<Object?> get props => <Object?>[selectedProvider, defaultWalletId];
}
