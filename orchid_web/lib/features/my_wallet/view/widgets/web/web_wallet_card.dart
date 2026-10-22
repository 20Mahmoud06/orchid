import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_fonts.dart';
import '../../../../../shared/widgets/custom_text.dart';
import '../wallet_provider.dart';
import 'web_wallet_edit_dialog.dart';
import 'web_wallet_identity.dart';
import 'web_wallet_logo_container.dart';
import 'web_wallet_provider_dropdown.dart';
import 'web_wallet_surface.dart';

/// The wallet card (front face + provider dropdown), matching the mobile
/// [WalletCard] at fixed logical pixels.
class WebWalletCard extends StatefulWidget {
  final Widget? walletLogo;
  final bool initialBalanceVisible;
  final WalletProvider? selectedProvider;
  final ValueChanged<WalletProvider>? onProviderChanged;
  final ValueChanged<bool>? onBalanceVisibilityChanged;
  final TextEditingController ownerNameController;
  final TextEditingController walletIdController;
  final TextEditingController balanceController;

  const WebWalletCard({
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

  @override
  State<WebWalletCard> createState() => _WebWalletCardState();
}

class _WebWalletCardState extends State<WebWalletCard> {
  late bool _balanceVisible;
  WalletProvider? _selectedProvider;

  @override
  void initState() {
    super.initState();
    _balanceVisible = widget.initialBalanceVisible;
    _selectedProvider = widget.selectedProvider;
  }

  @override
  void didUpdateWidget(covariant WebWalletCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The screen may restore the wallet picked last (browser/app cache) after
    // this card is already mounted, so keep the card in sync with it.
    if (oldWidget.selectedProvider != widget.selectedProvider) {
      _selectedProvider = widget.selectedProvider;
    }
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
    final dots = '•' * (id.length - 4);
    return '$dots${id.substring(id.length - 4)}';
  }

  void _toggleBalanceVisibility() {
    setState(() => _balanceVisible = !_balanceVisible);
    widget.onBalanceVisibilityChanged?.call(_balanceVisible);
  }

  void _updateProvider(WalletProvider provider) {
    setState(() => _selectedProvider = provider);
    widget.onProviderChanged?.call(provider);
  }

  Future<void> _editOwner(WalletProvider provider, bool isSelected) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => WebWalletEditDialog(
        title: 'Edit Owner Name',
        hint: 'Enter owner name',
        provider: provider,
        isProviderSelected: isSelected,
        initialValue: widget.ownerNameController.text,
        icon: Ionicons.person_outline,
      ),
    );
    if (result != null) {
      setState(() {
        widget.ownerNameController.value = TextEditingValue(text: result);
      });
    }
  }

  Future<void> _editWalletId(WalletProvider provider, bool isSelected) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => WebWalletEditDialog(
        title: 'Edit Wallet ID',
        hint: 'Enter wallet ID',
        provider: provider,
        isProviderSelected: isSelected,
        initialValue: widget.walletIdController.text,
        icon: Ionicons.card_outline,
      ),
    );
    if (result != null) {
      setState(() {
        widget.walletIdController.value = TextEditingValue(text: result);
      });
    }
  }

  Future<void> _editBalance(WalletProvider provider, bool isSelected) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => WebWalletEditDialog(
        title: 'Edit Balance',
        hint: 'Enter balance amount',
        keyboardType: TextInputType.number,
        provider: provider,
        isProviderSelected: isSelected,
        initialValue: widget.balanceController.text,
        icon: Ionicons.cash_outline,
      ),
    );
    if (result != null) {
      setState(() {
        widget.balanceController.value = TextEditingValue(text: result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = _selectedProvider ?? WalletProvider.providers.first;
    final isSelected = _selectedProvider != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        WebWalletSurface(
          provider: provider,
          isProviderSelected: isSelected,
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    WebWalletLogoContainer(
                      provider: provider,
                      isProviderSelected: isSelected,
                      child: widget.walletLogo,
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: isSelected
                                ? provider.name
                                : 'Select a Provider',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            fontFamily: AppFonts.goudyOldStyle,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            textColor: isSelected
                                ? provider.brandColor
                                : AppColors.textGrey,
                          ),
                          const SizedBox(height: 3),
                          const CustomText(
                            text: 'Digital Wallet',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            fontFamily: AppFonts.goudyOldStyle,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            textColor: AppColors.textGrey,
                          ),
                        ],
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: isSelected ? _toggleBalanceVisibility : null,
                        borderRadius: BorderRadius.circular(18),
                        child: Padding(
                          padding: const EdgeInsets.all(7),
                          child: Icon(
                            _balanceVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: isSelected
                                ? provider.brandColor
                                : AppColors.textGrey,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                CustomText(
                  text: 'AVAILABLE BALANCE',
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.3,
                  textColor: isSelected
                      ? provider.brandColor.withValues(alpha: 0.7)
                      : AppColors.textGrey.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 4),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 450),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position:
                            Tween<Offset>(
                              begin: const Offset(0, 0.3),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                              ),
                            ),
                        child: child,
                      ),
                    );
                  },
                  child: InkWell(
                    key: ValueKey(_balanceVisible),
                    onTap: isSelected
                        ? () => _editBalance(provider, isSelected)
                        : null,
                    child: CustomText(
                      text: isSelected
                          ? (_balanceVisible
                                ? _formattedBalance
                                : _maskedBalance)
                          : 'EGP ••••••••',
                      fontFamily: AppFonts.goudyOldStyle,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.7,
                      textColor: isSelected
                          ? provider.brandColor
                          : AppColors.textGrey.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: WebWalletIdentity(
                        label: 'WALLET OWNER',
                        value: isSelected
                            ? widget.ownerNameController.text.trim()
                            : '•••••••',
                        provider: provider,
                        isProviderSelected: isSelected,
                        onTap: isSelected
                            ? () => _editOwner(provider, isSelected)
                            : null,
                      ),
                    ),
                    Expanded(
                      child: WebWalletIdentity(
                        label: 'WALLET ID',
                        value: isSelected ? _maskedWalletId : '••••',
                        alignEnd: true,
                        provider: provider,
                        isProviderSelected: isSelected,
                        onTap: isSelected
                            ? () => _editWalletId(provider, isSelected)
                            : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        WebWalletProviderDropdown(
          selectedProvider: _selectedProvider,
          onChanged: _updateProvider,
          hintText: 'Choose your wallet provider',
        ),
      ],
    );
  }
}
