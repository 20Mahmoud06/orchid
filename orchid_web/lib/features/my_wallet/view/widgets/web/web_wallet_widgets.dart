import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_fonts.dart';
import '../../../../../core/utils/viewport.dart';
import '../../../../../shared/widgets/custom_button.dart';
import '../../../../../shared/widgets/custom_text.dart';
import '../wallet_provider.dart';

/// Desktop-first building blocks for the "my wallet" page.
///
/// Presentation only: the colors, copy and behaviour mirror the mobile screen
/// exactly, sized in fixed logical pixels (the web app pins the design size, so
/// these render 1:1 on any monitor — the same convention as the other web
/// pages).

/// Centered "my wallet" title (same copy as the mobile app bar).
class WebWalletHeader extends StatelessWidget {
  final VoidCallback? onBackPressed;

  const WebWalletHeader({super.key, this.onBackPressed});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 36,
      child: Center(
        child: CustomText(
          text: 'my wallet',
          fontFamily: AppFonts.goudyOldStyle,
          fontSize: 24,
          textColor: AppColors.black,
        ),
      ),
    );
  }
}

/// White rounded surface of the wallet card, matching the mobile
/// [WalletSurface] at fixed logical pixels.
class _WebWalletSurface extends StatelessWidget {
  final Widget child;
  final WalletProvider provider;
  final bool isProviderSelected;

  const _WebWalletSurface({
    required this.child,
    required this.provider,
    required this.isProviderSelected,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isProviderSelected
        ? provider.brandColor.withValues(alpha: 0.6)
        : AppColors.incrementButton;
    final shadowColor = isProviderSelected
        ? provider.brandColor.withValues(alpha: 0.15)
        : AppColors.incrementButton.withValues(alpha: 0.1);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: borderColor,
          width: isProviderSelected ? 2 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: isProviderSelected ? 22 : 10,
            offset: const Offset(0, 11),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

/// Small rounded provider logo box, mirroring the mobile [LogoContainer].
class _WebLogoContainer extends StatelessWidget {
  final WalletProvider provider;
  final bool isProviderSelected;
  final Widget? child;

  const _WebLogoContainer({
    required this.provider,
    required this.isProviderSelected,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isProviderSelected
            ? provider.lightColor
            : AppColors.incrementButton.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isProviderSelected
              ? provider.brandColor.withValues(alpha: 0.3)
              : AppColors.incrementButton.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      alignment: Alignment.center,
      child:
          child ??
          Icon(
            isProviderSelected
                ? (provider.icon ?? Icons.account_balance_wallet_outlined)
                : Icons.account_balance_wallet_outlined,
            color: isProviderSelected
                ? provider.brandColor
                : AppColors.textGrey.withValues(alpha: 0.5),
            size: 23,
          ),
    );
  }
}

/// Label + value block used for the wallet owner and wallet ID.
class _WebWalletIdentity extends StatelessWidget {
  final String label;
  final String value;
  final WalletProvider provider;
  final bool isProviderSelected;
  final bool alignEnd;
  final VoidCallback? onTap;

  const _WebWalletIdentity({
    required this.label,
    required this.value,
    required this.provider,
    required this.isProviderSelected,
    this.alignEnd = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        CustomText(
          text: label,
          fontFamily: AppFonts.goudyOldStyle,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
          textColor: isProviderSelected
              ? provider.brandColor.withValues(alpha: 0.6)
              : AppColors.textGrey.withValues(alpha: 0.4),
        ),
        const SizedBox(height: 5),
        CustomText(
          text: value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: alignEnd ? TextAlign.end : TextAlign.start,
          fontFamily: AppFonts.goudyOldStyle,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          textColor: isProviderSelected
              ? provider.brandColor
              : AppColors.textGrey.withValues(alpha: 0.4),
        ),
      ],
    );

    if (onTap == null) {
      return content;
    }
    return InkWell(onTap: onTap, child: content);
  }
}

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
        _WebWalletSurface(
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
                    _WebLogoContainer(
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
                      child: _WebWalletIdentity(
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
                      child: _WebWalletIdentity(
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

/// Wallet provider selector, mirroring the mobile [WalletProviderDropdown] with
/// fixed logical pixels.
class WebWalletProviderDropdown extends StatefulWidget {
  final WalletProvider? selectedProvider;
  final ValueChanged<WalletProvider> onChanged;
  final String hintText;

  const WebWalletProviderDropdown({
    super.key,
    required this.selectedProvider,
    required this.onChanged,
    this.hintText = 'Select Wallet Provider',
  });

  @override
  State<WebWalletProviderDropdown> createState() =>
      _WebWalletProviderDropdownState();
}

class _WebWalletProviderDropdownState extends State<WebWalletProviderDropdown>
    with SingleTickerProviderStateMixin {
  final GlobalKey _containerKey = GlobalKey();
  bool _isMenuOpen = false;
  OverlayEntry? _overlayEntry;
  OverlayEntry? _barrierEntry;
  Size _containerSize = Size.zero;

  late final AnimationController _menuAnimationController;

  @override
  void initState() {
    super.initState();
    _menuAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _menuAnimationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    if (_isMenuOpen) {
      _closeMenu();
    } else {
      _openMenu();
    }
  }

  void _openMenu() {
    final renderBox =
        _containerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final offset = renderBox.localToGlobal(Offset.zero);
    _containerSize = renderBox.size;

    final screenHeight = viewportHeight(context);
    final maxMenuHeight =
        (screenHeight - offset.dy - _containerSize.height - 80).clamp(
          0.0,
          300.0,
        );

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: offset.dy + _containerSize.height + 8,
        left: offset.dx,
        width: _containerSize.width,
        child: AnimatedBuilder(
          animation: _menuAnimationController,
          builder: (context, child) {
            return Opacity(
              opacity: _menuAnimationController.value,
              child: Transform.translate(
                offset: Offset(0, (1 - _menuAnimationController.value) * -10),
                child: child,
              ),
            );
          },
          child: Material(
            elevation: 8,
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            clipBehavior: Clip.antiAlias,
            child: Container(
              constraints: BoxConstraints(maxHeight: maxMenuHeight),
              width: _containerSize.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.incrementButton.withValues(alpha: 0.1),
                ),
              ),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: WalletProvider.providers.map((provider) {
                    final isSelectedProvider =
                        widget.selectedProvider?.name == provider.name;
                    return _buildMenuOption(provider, isSelectedProvider);
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    _barrierEntry = OverlayEntry(
      builder: (context) =>
          GestureDetector(behavior: HitTestBehavior.opaque, onTap: _closeMenu),
    );

    Overlay.of(context).insert(_barrierEntry!);
    Overlay.of(context).insert(_overlayEntry!);

    _menuAnimationController.reset();
    _menuAnimationController.forward();
    setState(() => _isMenuOpen = true);
  }

  void _closeMenu() {
    if (_overlayEntry != null) {
      _menuAnimationController.reverse().whenComplete(() {
        _barrierEntry?.remove();
        _barrierEntry = null;
        _overlayEntry?.remove();
        _overlayEntry = null;
        if (mounted) {
          setState(() => _isMenuOpen = false);
        }
      });
    }
  }

  Widget _buildMenuOption(WalletProvider provider, bool isSelectedProvider) {
    return InkWell(
      onTap: () {
        widget.onChanged(provider);
        _closeMenu();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        width: double.infinity,
        decoration: BoxDecoration(
          color: isSelectedProvider
              ? provider.lightColor.withValues(alpha: 0.25)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: provider.lightColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: provider.brandColor.withValues(alpha: 0.25),
                ),
              ),
              child: Icon(
                provider.icon ?? Icons.phone_android,
                color: provider.brandColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomText(
                text: provider.name,
                textColor: isSelectedProvider
                    ? provider.brandColor
                    : AppColors.textGrey,
                fontWeight: isSelectedProvider
                    ? FontWeight.w700
                    : FontWeight.w500,
                fontSize: 14,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isSelectedProvider)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: provider.brandColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: provider.brandColor,
                  size: 18,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.selectedProvider != null;
    final borderColor = isSelected
        ? widget.selectedProvider!.brandColor.withValues(alpha: 0.35)
        : AppColors.incrementButton;
    final textColor = isSelected
        ? widget.selectedProvider!.brandColor
        : AppColors.textGrey;

    return Container(
      key: _containerKey,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: isSelected ? 2 : 1.5),
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: widget.selectedProvider!.brandColor.withValues(
                alpha: 0.12,
              ),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
        ],
      ),
      child: InkWell(
        onTap: _toggleMenu,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isSelected
                      ? widget.selectedProvider!.lightColor
                      : AppColors.incrementButton.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? widget.selectedProvider!.brandColor.withValues(
                            alpha: 0.25,
                          )
                        : AppColors.incrementButton.withValues(alpha: 0.25),
                  ),
                ),
                child: Icon(
                  isSelected
                      ? (widget.selectedProvider!.icon ??
                            Icons.account_balance_wallet_outlined)
                      : Icons.account_balance_wallet_outlined,
                  color: isSelected
                      ? widget.selectedProvider!.brandColor
                      : AppColors.textGrey,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.1, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: isSelected
                      ? CustomText(
                          key: ValueKey(widget.selectedProvider!.name),
                          text: widget.selectedProvider!.name,
                          textColor: textColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        )
                      : CustomText(
                          key: ValueKey(widget.hintText),
                          text: widget.hintText,
                          textColor: AppColors.textGrey,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                ),
              ),
              AnimatedRotation(
                turns: _isMenuOpen ? 0.5 : 0,
                duration: const Duration(milliseconds: 250),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? widget.selectedProvider!.lightColor.withValues(
                            alpha: 0.4,
                          )
                        : AppColors.incrementButton.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.arrow_drop_down,
                    color: isSelected
                        ? widget.selectedProvider!.brandColor
                        : AppColors.textGrey,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Edit dialog for the wallet owner name / wallet ID / balance, mirroring the
/// mobile [WalletEditDialog] with fixed logical pixels.
class WebWalletEditDialog extends StatelessWidget {
  final String title;
  final String initialValue;
  final String hint;
  final TextInputType? keyboardType;
  final WalletProvider provider;
  final bool isProviderSelected;
  final IconData? icon;

  const WebWalletEditDialog({
    super.key,
    required this.title,
    required this.initialValue,
    required this.hint,
    this.keyboardType,
    required this.provider,
    required this.isProviderSelected,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: initialValue);
    final accent = isProviderSelected
        ? provider.brandColor
        : AppColors.incrementButton;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.background,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: isProviderSelected
                      ? provider.lightColor
                      : AppColors.incrementButton.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon ?? Ionicons.cash_outline,
                  size: 32,
                  color: isProviderSelected
                      ? provider.brandColor
                      : AppColors.textGrey,
                ),
              ),
              const SizedBox(height: 16),
              CustomText(
                text: title,
                fontFamily: AppFonts.goudyOldStyle,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                textColor: AppColors.black,
              ),
              const SizedBox(height: 10),
              CustomText(
                text: hint,
                fontFamily: AppFonts.inriaSerif,
                fontSize: 14,
                textColor: AppColors.textPrimary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 22),
              TextField(
                controller: controller,
                keyboardType: keyboardType ?? TextInputType.text,
                decoration: InputDecoration(
                  hintText: hint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: accent.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: accent.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: accent, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      label: 'CANCEL',
                      fontFamily: AppFonts.goudyOldStyle,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      textColor: AppColors.black,
                      backgroundColor: AppColors.white,
                      height: 48,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [],
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      label: 'SAVE',
                      fontFamily: AppFonts.goudyOldStyle,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      textColor: AppColors.black,
                      backgroundColor: isProviderSelected
                          ? provider.lightColor
                          : AppColors.textFieldPink,
                      height: 48,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [],
                      onPressed: () =>
                          Navigator.of(context).pop(controller.text.trim()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Modal shown when the shopper confirms a wallet payment. Same copy as the
/// mobile dialog, sized like the other desktop web dialogs.
class WebWalletConfirmationDialog extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const WebWalletConfirmationDialog({
    super.key,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.background,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.textFieldPink,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Ionicons.wallet_outline,
                  size: 32,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Confirm Wallet Payment',
                style: TextStyle(
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'The amount will be deducted from your wallet balance upon delivery. Do you want to confirm this order?',
                style: TextStyle(
                  fontFamily: AppFonts.inriaSerif,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textFieldPink,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'CONFIRM',
                    style: TextStyle(
                      fontFamily: AppFonts.goudyOldStyle,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.storeOutlineBorder),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'CANCEL',
                    style: TextStyle(
                      fontFamily: AppFonts.goudyOldStyle,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
