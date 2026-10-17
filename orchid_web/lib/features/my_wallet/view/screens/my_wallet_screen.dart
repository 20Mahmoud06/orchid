import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../core/app_keys.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/utils/viewport.dart';
import '../../../../features/auth/cubit/auth_cubit.dart';
import '../../../../features/checkout/checkout_flow.dart';
import '../../../../features/checkout/cubit/checkout_cubit.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text.dart';
import '../widgets/wallet_card.dart';
import '../widgets/wallet_provider.dart';
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
          return _buildWeb(context);
        }
        return _buildMobile(context);
      },
    );
  }

  /// Desktop-first "my wallet" page (>= 768px). Same colors, copy and behaviour
  /// as the mobile screen — a two-column layout like the other web checkout
  /// pages: the wallet illustration on the left and the wallet card with the
  /// CONFIRM action in the sidebar.
  Widget _buildWeb(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(40, 36, 40, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  WebWalletHeader(onBackPressed: widget.onBackPressed),
                  const SizedBox(height: 24),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, rowConstraints) {
                        final sideWidth = (rowConstraints.maxWidth * 0.40)
                            .clamp(360.0, 440.0);
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    const SizedBox(height: 12),
                                    Center(
                                      child: Image.asset(
                                        AppAssets.myWallet,
                                        width: 460,
                                        height: 340,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 28),
                            SizedBox(
                              width: sideWidth,
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    WebWalletCard(
                                      walletLogo: const Icon(
                                        Icons.account_balance_wallet_rounded,
                                        size: 22,
                                      ),
                                      initialBalanceVisible: false,
                                      selectedProvider: _selectedProvider,
                                      ownerNameController: _ownerNameController,
                                      walletIdController: _walletIdController,
                                      balanceController: _balanceController,
                                      onProviderChanged: _handleProviderChanged,
                                      onBalanceVisibilityChanged: (isVisible) {
                                        // balance visibility toggled
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    CustomButton(
                                      label: 'CONFIRM',
                                      fontFamily: AppFonts.goudyOldStyle,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      textColor: AppColors.black,
                                      backgroundColor: AppColors.textFieldPink,
                                      height: 52,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: const [],
                                      onPressed: _handleConfirm,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Mobile layout (unchanged).
  Widget _buildMobile(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomAppBar.orchid(
                title: 'my wallet',
                onBackPressed: widget.onBackPressed,
                centerWidget: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomText(
                      text: 'my wallet',
                      fontFamily: AppFonts.goudyOldStyle,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w400,
                      textColor: AppColors.black,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              Image.asset(
                AppAssets.myWallet,
                width: 280.w,
                height: 220.h,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 20.h),
              WalletCard(
                walletLogo: const Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 22,
                ),
                initialBalanceVisible: false,
                selectedProvider: _selectedProvider,
                ownerNameController: _ownerNameController,
                walletIdController: _walletIdController,
                balanceController: _balanceController,
                onProviderChanged: _handleProviderChanged,
                onBalanceVisibilityChanged: (isVisible) {
                  // balance visibility toggled
                },
              ),
              SizedBox(height: 140.h),
              CustomButton(
                label: 'CONFIRM',
                fontFamily: AppFonts.goudyOldStyle,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                textColor: AppColors.black,
                backgroundColor: AppColors.textFieldPink,
                height: 52.h,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: const [],
                onPressed: _handleConfirm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
