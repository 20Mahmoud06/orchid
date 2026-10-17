import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../core/app_keys.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/viewport.dart';
import '../../../../features/choose_flowers/view/widgets/web/web_choose_flowers_widgets.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../../../../shared/widgets/catalog_error_view.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text.dart';
import '../../../../shared/widgets/flower_category_tabs.dart';
import '../../../../shared/widgets/fade_slide_in.dart';
import '../../../../shared/widgets/slider_direction.dart';
import '../../cubit/orders_cubit.dart';
import '../../cubit/orders_state.dart';
import '../../models/customer_order.dart';
import '../widgets/order_empty_state.dart';
import '../widgets/order_history_card.dart';
import '../widgets/web/web_order_history_widgets.dart';

/// Live history of the signed-in customer's orders.
class OrderHistoryScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;

  const OrderHistoryScreen({super.key, this.onBackPressed});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen>
    with SingleTickerProviderStateMixin {
  int _selectedTabIndex = 0;

  late final AnimationController _controller;
  static const int _itemCount = 4;
  static const double _slideDistance = 14;
  static const SlideDirection _direction = SlideDirection.leftToRight;

  static const _tabs = <String>['All', 'Preparing', 'Completed', 'Canceled'];

  List<CustomerOrder> _filterOrders(List<CustomerOrder> orders) {
    switch (_selectedTabIndex) {
      case 1:
        return orders.where((o) => o.status == 'PREPARING').toList();
      case 2:
        return orders.where((o) => o.status == 'COMPLETED').toList();
      case 3:
        return orders.where((o) => o.status == 'CANCELED').toList();
      default:
        return orders;
    }
  }

  String get _emptyMessage {
    switch (_selectedTabIndex) {
      case 1:
        return 'no preparing orders yet';
      case 2:
        return 'no completed orders yet';
      case 3:
        return 'no canceled orders yet';
      default:
        return 'no orders yet';
    }
  }

  @override
  void initState() {
    super.initState();
    // Always refresh on open so a freshly placed order shows up without a hot
    // reload.
    OrdersCubit.instance.load(force: true);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Animation<double> _animFor(int index) {
    final start = (index / _itemCount) * 0.55;
    final end = (start + 0.45).clamp(0.0, 1.0);
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
  }

  /// Asks for confirmation, then cancels the order (status CANCELED). The order
  /// is never deleted, so the admin dashboard keeps it.
  Future<void> _confirmCancelOrder(CustomerOrder order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        // Desktop web presentation; narrow viewports keep the mobile dialog.
        if (isWideViewport(ctx)) {
          return const WebCancelOrderDialog(
            icon: Ionicons.close_circle_outline,
            title: 'Cancel this order?',
            message:
                'Are you sure you want to cancel this order? It stays in your account marked as canceled.',
            confirmLabel: 'CANCEL ORDER',
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
                    Ionicons.close_circle_outline,
                    size: 32.r,
                    color: AppColors.redText,
                  ),
                ),
                SizedBox(height: 16.h),
                CustomText(
                  text: 'Cancel this order?',
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  textColor: AppColors.black,
                ),
                SizedBox(height: 12.h),
                CustomText(
                  text:
                      'Are you sure you want to cancel this order? It stays in your account marked as canceled.',
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
                        label: 'KEEP',
                        fontFamily: AppFonts.goudyOldStyle,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        textColor: AppColors.black,
                        backgroundColor: AppColors.white,
                        height: 48.h,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: const [],
                        onPressed: () => Navigator.of(ctx).pop(false),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: CustomButton(
                        label: 'CANCEL ORDER',
                        fontFamily: AppFonts.goudyOldStyle,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        textColor: AppColors.white,
                        backgroundColor: AppColors.canceledText,
                        height: 48.h,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: const [],
                        onPressed: () => Navigator.of(ctx).pop(true),
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

    if (confirmed != true || !mounted) return;
    try {
      await OrdersCubit.instance.cancelOrder(order);
    } catch (_) {
      if (!mounted) return;
      final messenger = scaffoldMessengerKey.currentState;
      if (messenger == null) return;
      showAppSnackBarWith(
        messenger,
        'Could not cancel this order',
        isError: true,
      );
    }
  }

  void _openDetails(CustomerOrder order) {
    Navigator.pushNamed(context, AppRoutes.orderDetails, arguments: order);
  }

  Future<void> _confirmCancelAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        // Desktop web presentation; narrow viewports keep the mobile dialog.
        if (isWideViewport(ctx)) {
          return const WebCancelOrderDialog(
            icon: Ionicons.trash,
            title: 'Cancel all orders?',
            message:
                'All your orders will be marked as canceled. They stay in your account and in the dashboard.',
            confirmLabel: 'CANCEL ALL',
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
                    Ionicons.trash,
                    size: 32.r,
                    color: AppColors.redText,
                  ),
                ),
                SizedBox(height: 16.h),
                CustomText(
                  text: 'Cancel all orders?',
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  textColor: AppColors.black,
                ),
                SizedBox(height: 12.h),
                CustomText(
                  text:
                      'All your orders will be marked as canceled. They stay in your account and in the dashboard.',
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
                        label: 'KEEP',
                        fontFamily: AppFonts.goudyOldStyle,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        textColor: AppColors.black,
                        backgroundColor: AppColors.white,
                        height: 48.h,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: const [],
                        onPressed: () => Navigator.of(ctx).pop(false),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: CustomButton(
                        label: 'CANCEL ALL',
                        fontFamily: AppFonts.goudyOldStyle,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        textColor: AppColors.white,
                        backgroundColor: AppColors.canceledText,
                        height: 48.h,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: const [],
                        onPressed: () => Navigator.of(ctx).pop(true),
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

    if (confirmed == true && mounted) {
      try {
        await OrdersCubit.instance.cancelAll();
      } catch (_) {
        if (!mounted) return;
        final messenger = scaffoldMessengerKey.currentState;
        if (messenger == null) return;
        showAppSnackBarWith(
          messenger,
          'Could not cancel your orders',
          isError: true,
        );
      }
    }
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

  /// Desktop-first orders history page (>= 768px). Same colors, copy and
  /// behaviour as the mobile screen — the title with the cancel-all action on
  /// top, then the status tabs and the order cards centered in a readable
  /// column.
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
                  BlocBuilder<OrdersCubit, OrdersState>(
                    bloc: OrdersCubit.instance,
                    builder: (context, state) {
                      final hasOrders = OrdersCubit.instance.orders.isNotEmpty;
                      return WebOrderHistoryHeader(
                        showCancelAll: hasOrders,
                        onCancelAll: _confirmCancelAll,
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 760),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            WebFlowerCategoryTabs(
                              categories: _tabs,
                              selectedIndex: _selectedTabIndex,
                              onCategorySelected: (index) {
                                setState(() => _selectedTabIndex = index);
                              },
                            ),
                            const SizedBox(height: 20),
                            Expanded(
                              child: BlocBuilder<OrdersCubit, OrdersState>(
                                bloc: OrdersCubit.instance,
                                builder: (context, state) =>
                                    _buildOrdersBody(context, web: true),
                              ),
                            ),
                          ],
                        ),
                      ),
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
        child: Column(
          children: [
            FadeSlideIn(
              animation: _animFor(0),
              direction: _direction,
              distance: _slideDistance,
              child: BlocBuilder<OrdersCubit, OrdersState>(
                bloc: OrdersCubit.instance,
                builder: (context, state) {
                  final hasOrders = OrdersCubit.instance.orders.isNotEmpty;
                  return CustomAppBar.orchid(
                    title: 'orders history',
                    onBackPressed: widget.onBackPressed,
                    actions: !hasOrders
                        ? null
                        : [
                            AppBarAction(
                              icon: Ionicons.trash,
                              color: AppColors.redText,
                              onPressed: _confirmCancelAll,
                            ),
                          ],
                  );
                },
              ),
            ),
            SizedBox(height: 10.h),
            FadeSlideIn(
              animation: _animFor(1),
              direction: _direction,
              distance: _slideDistance,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: FlowerCategoryTabs(
                  categories: _tabs,
                  selectedIndex: _selectedTabIndex,
                  onCategorySelected: (index) {
                    setState(() => _selectedTabIndex = index);
                  },
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: FadeSlideIn(
                animation: _animFor(2),
                direction: _direction,
                distance: _slideDistance,
                child: BlocBuilder<OrdersCubit, OrdersState>(
                  bloc: OrdersCubit.instance,
                  builder: (context, state) =>
                      _buildOrdersBody(context, web: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Loading / error / empty / order list, shared by both layouts. The web
  /// layout uses the fixed-pixel counterparts of the mobile widgets.
  Widget _buildOrdersBody(BuildContext context, {required bool web}) {
    final controller = OrdersCubit.instance;
    if (controller.isLoading && !controller.isLoaded) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.error != null && !controller.isLoaded) {
      return web
          ? WebOrdersErrorView(
              message: 'Could not load your orders',
              onRetry: () => controller.load(force: true),
            )
          : CatalogErrorView(
              message: 'Could not load your orders',
              onRetry: () => controller.load(force: true),
            );
    }
    final filtered = _filterOrders(controller.orders);
    if (filtered.isEmpty) {
      return web
          ? WebOrderEmptyState(message: _emptyMessage)
          : OrderEmptyState(message: _emptyMessage);
    }
    return RefreshIndicator(
      onRefresh: () => controller.load(force: true),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: web
            ? const EdgeInsets.only(bottom: 24)
            : EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
        itemCount: filtered.length,
        separatorBuilder: (context, index) => SizedBox(height: web ? 16 : 16.h),
        itemBuilder: (context, index) {
          final order = filtered[index];
          final date = _formatDate(order.createdAt);
          final image = order.coverImageUrl ?? AppAssets.bouquetTest;
          if (web) {
            return WebOrderHistoryCard(
              title: order.title,
              orderId: order.displayCode,
              date: date,
              price: order.total,
              status: order.status,
              image: image,
              onTap: () => _openDetails(order),
              onRemove: () => _confirmCancelOrder(order),
            );
          }
          return OrderHistoryCard(
            title: order.title,
            orderId: order.displayCode,
            date: date,
            price: order.total,
            status: order.status,
            image: image,
            onTap: () => _openDetails(order),
            onRemove: () => _confirmCancelOrder(order),
          );
        },
      ),
    );
  }

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String _formatDate(DateTime date) =>
      '${date.day} ${_months[date.month - 1]} ${date.year}';
}
