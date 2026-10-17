import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_text.dart';
import 'wallet_provider.dart';

class WalletProviderDropdown extends StatefulWidget {
  const WalletProviderDropdown({
    super.key,
    required this.selectedProvider,
    required this.onChanged,
    this.isExpanded = false,
    this.hintText = 'Select Wallet Provider',
  });

  final WalletProvider? selectedProvider;
  final ValueChanged<WalletProvider> onChanged;
  final bool isExpanded;
  final String hintText;

  @override
  State<WalletProviderDropdown> createState() => _WalletProviderDropdownState();
}

class _WalletProviderDropdownState extends State<WalletProviderDropdown>
    with SingleTickerProviderStateMixin {
  final GlobalKey _containerKey = GlobalKey();
  bool _isMenuOpen = false;
  OverlayEntry? _overlayEntry;
  Size _containerSize = Size.zero;
  OverlayEntry? _barrierEntry;

  late final AnimationController _menuAnimationController;

  @override
  void initState() {
    super.initState();
    _menuAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateContainerSize();
    });
  }

  void _updateContainerSize() {
    final RenderBox? renderBox =
        _containerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      setState(() {
        _containerSize = renderBox.size;
      });
    }
  }

  void _toggleMenu() {
    if (_isMenuOpen) {
      _closeMenu();
    } else {
      _openMenu();
    }
  }

  void _openMenu() {
    final RenderBox? renderBox =
        _containerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final Offset offset = renderBox.localToGlobal(Offset.zero);
    _containerSize = renderBox.size;

    // Calculate available space below, and adjust if needed (simple clamp)
    final screenHeight = MediaQuery.of(context).size.height;
    final maxMenuHeight =
        (screenHeight - offset.dy - _containerSize.height - 100.h).clamp(
          0.0,
          300.h,
        );

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: offset.dy + _containerSize.height + 8.h,
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
            borderRadius: BorderRadius.circular(18.r),
            clipBehavior: Clip.antiAlias,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: maxMenuHeight, // Dynamic height based on screen
              ),
              width: _containerSize.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(
                  color: AppColors.incrementButton.withValues(alpha: 0.1),
                ),
              ),
              child: SingleChildScrollView(
                physics:
                    const ClampingScrollPhysics(), // Smooth scroll and stops at edge
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...WalletProvider.providers.map((provider) {
                      final isSelectedProvider =
                          widget.selectedProvider?.name == provider.name;
                      return _buildMenuOption(provider, isSelectedProvider);
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // Add a barrier to close menu when tapping outside (STORE it in _barrierEntry)
    _barrierEntry = OverlayEntry(
      builder: (context) =>
          GestureDetector(behavior: HitTestBehavior.opaque, onTap: _closeMenu),
    );

    Overlay.of(context).insert(_barrierEntry!);
    Overlay.of(context).insert(_overlayEntry!);

    // Trigger animation
    _menuAnimationController.reset();
    _menuAnimationController.forward();
    setState(() {
      _isMenuOpen = true;
    });
  }

  void _closeMenu() {
    if (_overlayEntry != null) {
      _menuAnimationController.reverse().whenComplete(() {
        // Remove both entries specifically
        _barrierEntry?.remove();
        _barrierEntry = null;

        _overlayEntry?.remove();
        _overlayEntry = null;

        if (mounted) {
          setState(() {
            _isMenuOpen = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _menuAnimationController.dispose();
    super.dispose();
  }

  Widget _buildMenuOption(WalletProvider provider, bool isSelectedProvider) {
    return InkWell(
      onTap: () {
        widget.onChanged(provider);
        _closeMenu();
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        width: double.infinity,
        decoration: BoxDecoration(
          color: isSelectedProvider
              ? provider.lightColor.withValues(alpha: 0.25)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Row(
          children: [
            Container(
              width: 32.r,
              height: 32.r,
              decoration: BoxDecoration(
                color: provider.lightColor,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: provider.brandColor.withValues(alpha: 0.25),
                ),
              ),
              child: Icon(
                provider.icon ?? Icons.phone_android,
                color: provider.brandColor,
                size: 18.r,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: CustomText(
                text: provider.name,
                textColor: isSelectedProvider
                    ? provider.brandColor
                    : AppColors.textGrey,
                fontWeight: isSelectedProvider
                    ? FontWeight.w700
                    : FontWeight.w500,
                fontSize: 14.sp,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isSelectedProvider)
              Container(
                padding: EdgeInsets.all(4.r),
                decoration: BoxDecoration(
                  color: provider.brandColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: provider.brandColor,
                  size: 18.r,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isSelected = widget.selectedProvider != null;
    final Color borderColor = isSelected
        ? widget.selectedProvider!.brandColor.withValues(alpha: 0.35)
        : AppColors.incrementButton;
    final Color textColor = isSelected
        ? widget.selectedProvider!.brandColor
        : AppColors.textGrey;

    return Container(
      key: _containerKey,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: borderColor, width: isSelected ? 2.w : 1.5.w),
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: widget.selectedProvider!.brandColor.withValues(
                alpha: 0.12,
              ),
              blurRadius: 12.r,
              offset: Offset(0, 6.h),
            ),
        ],
      ),
      child: InkWell(
        onTap: _toggleMenu,
        borderRadius: BorderRadius.circular(18.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
          child: Row(
            children: [
              Container(
                width: 32.r,
                height: 32.r,
                decoration: BoxDecoration(
                  color: isSelected
                      ? widget.selectedProvider!.lightColor
                      : AppColors.incrementButton.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.r),
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
                  size: 18.r,
                ),
              ),
              SizedBox(width: 12.w),
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
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        )
                      : CustomText(
                          key: ValueKey(widget.hintText),
                          text: widget.hintText,
                          textColor: AppColors.textGrey,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                ),
              ),
              AnimatedRotation(
                turns: _isMenuOpen ? 0.5 : 0,
                duration: const Duration(milliseconds: 250),
                child: Container(
                  padding: EdgeInsets.all(6.r),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? widget.selectedProvider!.lightColor.withValues(
                            alpha: 0.4,
                          )
                        : AppColors.incrementButton.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.arrow_drop_down,
                    color: isSelected
                        ? widget.selectedProvider!.brandColor
                        : AppColors.textGrey,
                    size: 24.r,
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
