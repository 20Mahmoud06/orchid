import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/viewport.dart';
import '../../../../../shared/widgets/custom_text.dart';
import '../wallet_provider.dart';

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
