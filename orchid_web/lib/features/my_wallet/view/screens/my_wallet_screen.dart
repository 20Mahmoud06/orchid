import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../core/app_keys.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/utils/viewport.dart';
import '../../../../features/auth/cubit/auth_cubit.dart';
import '../../../../features/checkout/checkout_flow.dart';
import '../../../../features/checkout/cubit/checkout_cubit.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text.dart';
import '../widgets/my_wallet_mobile_view.dart';
import '../widgets/wallet_provider.dart';
import '../widgets/web/my_wallet_web_view.dart';
import '../widgets/web/web_wallet_widgets.dart';

class MyWalletScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;

  const MyWalletScreen({super.key, this.onBackPressed});

  @override
  State<MyWalletScreen> createState() => _MyWalletScreenState();
}

class _MyWalletScreenState extends State<MyWalletScreen> {
  final TextEditingController _ownerNameController = TextEditingController(
    text: 'Mahmoud Safa',
  );
  final TextEditingController _walletIdController = TextEditingController(
    text: '4821',
  );
  final TextEditingController _balanceController = TextEditingController(
    text: '0',
  );

  // The wallet the user picked. Its balance and ID are stored per provider, so
  // switching wallets shows that wallet's own number and money.
  WalletProvider? _selectedProvider;
  String _defaultWalletId = '4821';
  bool _isSwitchingProvider = false;

  @override
  void initState() {
    super.initState();
    _restoreWallet();
    _balanceController.addListener(_persistProviderData);
    _walletIdController.addListener(_persistProviderData);
  }

  @override
  void dispose() {
    _balanceController.removeListener(_persistProviderData);
    _walletIdController.removeListener(_persistProviderData);
    _ownerNameController.dispose();
    _walletIdController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  /// Uses the signed-in user's phone number as the default wallet ID (only its
  /// last four digits are ever shown). Each provider keeps its own saved ID.
  /// Also restores the wallet picked last (kept in the browser/app cache) so a
  /// refresh brings back the same provider together with its balance.
  Future<void> _restoreWallet() async {
    final phone = AuthCubit.instance.userProfile?.phone ?? '';
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final savedProvider = await AppPrefs.instance.getString(
      AppPrefKeys.walletProvider,
    );
    if (!mounted) return;
    setState(() {
      if (digits.length >= 4) {
        _defaultWalletId = digits;
        _walletIdController.text = digits;
      }
    });
    if (savedProvider == null || savedProvider.isEmpty) return;
    if (!WalletProvider.providers.any((p) => p.name == savedProvider)) return;
    await _handleProviderChanged(WalletProvider.fromName(savedProvider));
  }

  /// Persists the current balance and ID for the selected provider.
  void _persistProviderData() {
    final provider = _selectedProvider;
    if (provider == null || _isSwitchingProvider) return;
    _saveProvider(provider);
  }

  void _saveProvider(WalletProvider provider) {
    AppPrefs.instance.saveString(
      AppPrefKeys.walletBalanceKey(provider.name),
      _balanceController.text,
    );
    AppPrefs.instance.saveString(
      AppPrefKeys.walletIdKey(provider.name),
      _walletIdController.text,
    );
    AppPrefs.instance.saveString(AppPrefKeys.walletProvider, provider.name);
  }

  /// Saves the outgoing wallet and loads the newly picked wallet's own balance
  /// and ID.
  Future<void> _handleProviderChanged(WalletProvider provider) async {
    final previous = _selectedProvider;
    if (previous != null && previous.name != provider.name) {
      _saveProvider(previous);
    }

    final savedBalance = await AppPrefs.instance.getString(
      AppPrefKeys.walletBalanceKey(provider.name),
    );
    final savedWalletId = await AppPrefs.instance.getString(
      AppPrefKeys.walletIdKey(provider.name),
    );
    if (!mounted) return;

    _isSwitchingProvider = true;
    setState(() {
      _selectedProvider = provider;
      _balanceController.text = savedBalance == null || savedBalance.isEmpty
          ? '0'
          : savedBalance;
      _walletIdController.text = savedWalletId == null || savedWalletId.isEmpty
          ? _defaultWalletId
          : savedWalletId;
    });
    _isSwitchingProvider = false;
  }

  double get _walletBalance {
    final raw = _balanceController.text.trim().replaceAll(',', '');
    return double.tryParse(raw) ?? 0;
  }

  void _handleConfirm() {
    final total = CheckoutCubit.instance.totalPrice;
    final balance = _walletBalance;
    final messenger = ScaffoldMessenger.of(context);

    if (balance <= 0) {
      showAppSnackBarWith(
        messenger,
        'Your wallet balance is 0. Add money to your wallet to pay with it.',
        isError: true,
      );
      return;
    }

    if (balance < total) {
      showAppSnackBarWith(
        messenger,
        'Insufficient wallet balance. Your balance is EGP '
        '${balance.toStringAsFixed(2)} but this order totals EGP '
        '${total.toDouble().toStringAsFixed(2)}.',
        isError: true,
      );
      return;
    }

    _showWalletConfirmationDialog(context);
  }

  Future<void> _showWalletConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (ctx) {
        // The web build pins `MediaQuery.size` to the phone design size, so the
        // desktop decision has to read the real viewport. Mobile is unchanged.
        if (isWideViewport(ctx)) {
          return WebWalletConfirmationDialog(
            onCancel: () => Navigator.of(ctx).pop(),
            onConfirm: () {
              Navigator.of(ctx).pop();
              submitCheckoutAndConfirm(context, paymentMethod: 'wallet');
            },
          );
        }
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          backgroundColor: AppColors.background,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64.r,
                  height: 64.r,
                  decoration: BoxDecoration(
                    color: AppColors.textFieldPink,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Ionicons.wallet_outline,
                    size: 32.r,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: 16.h),
                CustomText(
                  text: 'Confirm Wallet Payment',
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  textColor: AppColors.black,
                ),
                SizedBox(height: 12.h),
                CustomText(
                  text:
                      'The amount will be deducted from your wallet balance upon delivery. Do you want to confirm this order?',
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 14.sp,
                  textColor: AppColors.textPrimary,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        label: 'CANCEL',
                        fontFamily: AppFonts.goudyOldStyle,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        textColor: AppColors.black,
                        backgroundColor: AppColors.white,
                        height: 48.h,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: const [],
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: CustomButton(
                        label: 'CONFIRM',
                        fontFamily: AppFonts.goudyOldStyle,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        textColor: AppColors.black,
                        backgroundColor: AppColors.textFieldPink,
                        height: 48.h,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: const [],
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          submitCheckoutAndConfirm(
                            context,
                            paymentMethod: 'wallet',
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Desktop-first web presentation (>= 768px). Narrow viewports keep the
        // untouched Orchid mobile layout.
        if (constraints.maxWidth >= 768) {
          return MyWalletWebView(
            onBackPressed: widget.onBackPressed,
            selectedProvider: _selectedProvider,
            ownerNameController: _ownerNameController,
            walletIdController: _walletIdController,
            balanceController: _balanceController,
            onProviderChanged: _handleProviderChanged,
            onConfirm: _handleConfirm,
          );
        }
        return MyWalletMobileView(
          onBackPressed: widget.onBackPressed,
          selectedProvider: _selectedProvider,
          ownerNameController: _ownerNameController,
          walletIdController: _walletIdController,
          balanceController: _balanceController,
          onProviderChanged: _handleProviderChanged,
          onConfirm: _handleConfirm,
        );
      },
    );
  }
}
