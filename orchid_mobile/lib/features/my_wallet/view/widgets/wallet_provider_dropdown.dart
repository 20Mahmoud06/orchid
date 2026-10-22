import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'wallet_provider.dart';
import 'wallet_provider_dropdown_field.dart';
import 'wallet_provider_dropdown_menu.dart';

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

  late final AnimationController _menuAnimationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
  );

  @override
  void initState() {
    super.initState();
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
        (screenHeight - offset.dy - _containerSize.height - 100.h)
            .clamp(0.0, 300.h);

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
          child: WalletProviderDropdownMenu(
            width: _containerSize.width,
            maxHeight: maxMenuHeight,
            selectedProvider: widget.selectedProvider,
            onSelected: (provider) {
              widget.onChanged(provider);
              _closeMenu();
            },
          ),
        ),
      ),
    );

    // Add a barrier to close menu when tapping outside (STORE it in _barrierEntry)
    _barrierEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _closeMenu,
      ),
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

  @override
  Widget build(BuildContext context) {
    return WalletProviderDropdownField(
      containerKey: _containerKey,
      selectedProvider: widget.selectedProvider,
      hintText: widget.hintText,
      isMenuOpen: _isMenuOpen,
      onTap: _toggleMenu,
    );
  }
}
