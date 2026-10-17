import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';

/// Reusable, desktop-first building blocks for the Orchid web authentication
/// pages (Login, Sign-up, Forgot password).
///
/// These widgets only own presentation. All authentication logic stays in
/// [AuthCubit]/the screens — nothing here talks to Supabase.
///
/// Sizing uses fixed logical pixels (not `flutter_screenutil`) because on the
/// web the app pins the design size, so these values render 1:1 on any monitor.

/// Centered, scrollable page shell with a soft botanical background.
///
/// Vertically centers [card] on tall screens and lets it scroll naturally when
/// the viewport is short (e.g. a laptop with the browser chrome open). The
/// [leading] widget (typically a back button) is pinned to the top-left of the
/// viewport, outside the centered column.
class AuthWebScaffold extends StatelessWidget {
  final Widget card;
  final Widget? leading;
  final double maxWidth;

  const AuthWebScaffold({
    super.key,
    required this.card,
    this.leading,
    this.maxWidth = 460,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const Positioned.fill(child: _AuthBackground()),
          if (leading != null)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: leading,
              ),
            ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 480;
                final outerPadding = compact ? 20.0 : 32.0;
                final minHeight =
                    math.max(0.0, constraints.maxHeight - outerPadding * 2);

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: outerPadding,
                    vertical: outerPadding,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: minHeight),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxWidth),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const AuthBrandHeader(),
                            SizedBox(height: compact ? 26 : 34),
                            card,
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthBackground extends StatelessWidget {
  const _AuthBackground();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          const Positioned(
            top: -130,
            left: -110,
            child: _Glow(
              color: Colors.white,
              size: 380,
              opacity: 0.75,
            ),
          ),
          const Positioned(
            bottom: -150,
            right: -120,
            child: _Glow(
              color: Colors.white,
              size: 460,
              opacity: 0.7,
            ),
          ),
          Positioned(
            bottom: -70,
            right: -60,
            child: Opacity(
              opacity: 0.05,
              child: Image.asset(
                AppAssets.bigFlowerSplash,
                width: 340,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  final Color color;
  final double size;
  final double opacity;

  const _Glow({
    required this.color,
    required this.size,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: opacity),
            color.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}

/// Orchid logo + wordmark header used at the top of every auth page.
class AuthBrandHeader extends StatelessWidget {
  const AuthBrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          AppAssets.smallFlowerSplash,
          height: 56,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 10),
        const Text(
          'ORCHID',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 42,
            height: 1,
            letterSpacing: 1.5,
            color: AppColors.darkGreen,
          ),
        ),
        const SizedBox(height: 3),
        const Text(
          'flower shop',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppFonts.goudyBookletter,
            fontSize: 17,
            height: 1,
            letterSpacing: 0.5,
            color: AppColors.flowerShopGreen,
          ),
        ),
      ],
    );
  }
}

/// White authentication panel with a restrained border and soft shadow.
class AuthCard extends StatelessWidget {
  final Widget child;

  const AuthCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontal = constraints.maxWidth < 400 ? 24.0 : 36.0;
        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: horizontal,
            vertical: 40,
          ),
          decoration: BoxDecoration(
            color: AppColors.authSection,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.cardBorder.withValues(alpha: 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: child,
        );
      },
    );
  }
}

/// Page title + optional supporting sentence.
class AuthHeading extends StatelessWidget {
  final String title;
  final String? subtitle;

  const AuthHeading({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: AppFonts.goudyOldStyle,
            fontSize: 30,
            height: 1.15,
            color: AppColors.darkGreen,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 10),
          Text(
            subtitle!,
            style: const TextStyle(
              fontFamily: AppFonts.inriaSerif,
              fontSize: 15,
              height: 1.45,
              color: Colors.black87,
            ),
          ),
        ],
      ],
    );
  }
}

/// Labeled text input with an optional password visibility toggle and inline
/// validation message.
class AuthTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final bool isPassword;
  final TextInputType? keyboardType;
  final String? errorText;
  final bool enabled;
  final List<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final Widget? prefixIcon;
  final List<TextInputFormatter>? inputFormatters;

  const AuthTextField({
    super.key,
    this.controller,
    required this.label,
    this.hint,
    this.isPassword = false,
    this.keyboardType,
    this.errorText,
    this.enabled = true,
    this.autofillHints,
    this.onSubmitted,
    this.onChanged,
    this.prefixIcon,
    this.inputFormatters,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late bool _obscure = widget.isPassword;

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;
    final borderColor = hasError
        ? AppColors.error
        : AppColors.cardBorder.withValues(alpha: 0.6);

    final baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: borderColor),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontFamily: AppFonts.inriaSerif,
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: AppColors.darkGreen,
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: widget.controller,
          enabled: widget.enabled,
          obscureText: widget.isPassword && _obscure,
          keyboardType: widget.keyboardType,
          autofillHints: widget.autofillHints,
          inputFormatters: widget.inputFormatters,
          onSubmitted: widget.onSubmitted,
          onChanged: widget.onChanged,
          style: const TextStyle(
            fontFamily: AppFonts.inriaSerif,
            fontSize: 15,
            color: AppColors.textFieldText,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(
              fontFamily: AppFonts.inriaSerif,
              fontSize: 15,
              color: AppColors.textSecondary.withValues(alpha: 0.7),
            ),
            prefixIcon: widget.prefixIcon,
            prefixIconColor: AppColors.iconColor,
            filled: true,
            fillColor: widget.enabled
                ? AppColors.designFieldPink
                : AppColors.fieldDisabledPink,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: baseBorder,
            enabledBorder: baseBorder,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError
                    ? AppColors.error
                    : AppColors.selectedCategory,
                width: 1.6,
              ),
            ),
            errorBorder: baseBorder,
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 1.6),
            ),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.iconColor,
                      size: 21,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  )
                : null,
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 2),
            child: Text(
              widget.errorText!,
              style: const TextStyle(
                fontFamily: AppFonts.inriaSerif,
                fontSize: 12.5,
                height: 1.3,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Full-width primary call-to-action button.
class AuthPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const AuthPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.buttonPink,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: isLoading ? null : onPressed,
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.darkGreen,
                        ),
                      ),
                    )
                  : Text(
                      label,
                      style: const TextStyle(
                        fontFamily: AppFonts.inriaSerif,
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                        color: AppColors.darkGreen,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Inline text link (e.g. "Forgot password?").
class AuthLink extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final Color? color;

  const AuthLink({super.key, required this.text, this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final linkColor = color ?? AppColors.linkPurple;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Text(
          text,
          style: TextStyle(
            fontFamily: AppFonts.inriaSerif,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: linkColor,
          ),
        ),
      ),
    );
  }
}

/// Centered "Already have an account? Sign in" style prompt.
class AuthInlinePrompt extends StatelessWidget {
  final String leading;
  final String action;
  final VoidCallback? onTap;

  const AuthInlinePrompt({
    super.key,
    required this.leading,
    required this.action,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            leading,
            style: TextStyle(
              fontFamily: AppFonts.inriaSerif,
              fontSize: 14,
              color: AppColors.black.withValues(alpha: 0.7),
            ),
          ),
        ),
        const SizedBox(width: 5),
        AuthLink(text: action, onTap: onTap),
      ],
    );
  }
}

/// Compact inline error message (general/network errors).
class AuthErrorText extends StatelessWidget {
  final String message;

  const AuthErrorText({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.error_outline,
          color: AppColors.error,
          size: 16,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(
              fontFamily: AppFonts.inriaSerif,
              fontSize: 13,
              height: 1.3,
              color: AppColors.error,
            ),
          ),
        ),
      ],
    );
  }
}
