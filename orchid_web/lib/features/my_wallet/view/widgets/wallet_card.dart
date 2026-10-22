import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ionicons/ionicons.dart';

import 'wallet_edit_dialog.dart';
import 'wallet_front.dart';
import 'wallet_provider.dart';
import 'wallet_provider_dropdown.dart';

class WalletCard extends StatefulWidget {
  const WalletCard({
    super.key,
    this.walletLogo,
    this.initialBalanceVisible = true,
    this.selectedProvider,
    this.onProviderChanged,
    this.onBalanceVisibilityChanged,
    required this.ownerNameController,
    required this.walletIdController,
    required this.balanceController,
  });

  final Widget? walletLogo;
  final bool initialBalanceVisible;
  final WalletProvider? selectedProvider;
  final ValueChanged<WalletProvider>? onProviderChanged;
  final ValueChanged<bool>? onBalanceVisibilityChanged;
  final TextEditingController ownerNameController;
  final TextEditingController walletIdController;
  final TextEditingController balanceController;

  @override
  State<WalletCard> createState() => _WalletCardState();
}

class _WalletCardState extends State<WalletCard>
    with SingleTickerProviderStateMixin {
  late bool _balanceVisible;
  WalletProvider? _selectedProvider;
  late AnimationController _eyeAnimationController;

  @override
  void initState() {
    super.initState();
    _balanceVisible = widget.initialBalanceVisible;
    _selectedProvider = widget.selectedProvider;

    _eyeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void didUpdateWidget(covariant WalletCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The screen may restore the wallet picked last (browser/app cache) after
    // this card is already mounted, so keep the card in sync with it.
    if (oldWidget.selectedProvider != widget.selectedProvider) {
      _selectedProvider = widget.selectedProvider;
    }
  }

  @override
  void dispose() {
    _eyeAnimationController.dispose();
    super.dispose();
  }

  String get _formattedBalance {
    final raw = widget.balanceController.text.trim();
    final value = double.tryParse(raw) ?? 0.0;
    final fixed = value.toStringAsFixed(2);
    final parts = fixed.split('.');

    final formattedWhole = parts.first.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );

    return 'EGP $formattedWhole.${parts.last}';
  }

  String get _maskedBalance => 'EGP ••••••••';

  String get _maskedWalletId {
    final id = widget.walletIdController.text.trim();

    if (id.isEmpty) {
      return '••••';
    }

    if (id.length <= 4) {
      return '•••• $id';
    }

    // Hide all but the last four characters, one bullet per hidden char, so an
    // 11-digit phone number reads as 7 dots followed by its last 4 digits.
    final dots = '•' * (id.length - 4);
    return '$dots${id.substring(id.length - 4)}';
  }

  void _toggleBalanceVisibility() {
    setState(() {
      _balanceVisible = !_balanceVisible;
    });

    _eyeAnimationController.reset();
    _eyeAnimationController.forward();

    widget.onBalanceVisibilityChanged?.call(_balanceVisible);
  }

  void _updateProvider(WalletProvider provider) {
    setState(() {
      _selectedProvider = provider;
    });
    widget.onProviderChanged?.call(provider);
  }

  @override
  Widget build(BuildContext context) {
    final provider = _selectedProvider ?? WalletProvider.providers.first;
    final bool isProviderSelected = _selectedProvider != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        WalletFront(
          walletName: provider.name,
          walletType: 'Digital Wallet',
          ownerName: widget.ownerNameController.text.trim(),
          maskedWalletId: _maskedWalletId,
          balance: _balanceVisible ? _formattedBalance : _maskedBalance,
          balanceVisible: _balanceVisible,
          walletLogo: widget.walletLogo,
          onToggleBalance: _toggleBalanceVisibility,
          provider: provider,
          eyeAnimation: _eyeAnimationController,
          isProviderSelected: isProviderSelected,
          currency: 'EGP',
          onEditOwner: () async {
            final result = await showDialog<String>(
              context: context,
              builder: (context) => WalletEditDialog(
                title: 'Edit Owner Name',
                hint: 'Enter owner name',
                provider: provider,
                isProviderSelected: isProviderSelected,
                initialValue: widget.ownerNameController.text,
                icon: Ionicons.person_outline,
              ),
            );
            if (result != null) {
              setState(() {
                widget.ownerNameController.value = TextEditingValue(
                  text: result,
                );
              });
            }
          },
          onEditWalletId: () async {
            final result = await showDialog<String>(
              context: context,
              builder: (context) => WalletEditDialog(
                title: 'Edit Wallet ID',
                hint: 'Enter wallet ID',
                provider: provider,
                isProviderSelected: isProviderSelected,
                initialValue: widget.walletIdController.text,
                icon: Ionicons.card_outline,
              ),
            );
            if (result != null) {
              setState(() {
                widget.walletIdController.value = TextEditingValue(
                  text: result,
                );
              });
            }
          },
          onEditBalance: () async {
            final result = await showDialog<String>(
              context: context,
              builder: (context) => WalletEditDialog(
                title: 'Edit Balance',
                hint: 'Enter balance amount',
                keyboardType: TextInputType.number,
                provider: provider,
                isProviderSelected: isProviderSelected,
                initialValue: widget.balanceController.text,
                icon: Ionicons.cash_outline,
              ),
            );
            if (result != null) {
              setState(() {
                widget.balanceController.value = TextEditingValue(text: result);
              });
            }
          },
        ),
        SizedBox(height: 16.h),
        WalletProviderDropdown(
          selectedProvider: _selectedProvider,
          onChanged: _updateProvider,
          hintText: 'Choose your wallet provider',
        ),
      ],
    );
  }
}
