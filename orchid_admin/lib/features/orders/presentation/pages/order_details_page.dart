import 'package:flutter/material.dart';

import '../../../../app/router/app_nav.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_text.dart';
import '../../data/repositories/orders_repository.dart';
import '../../domain/models/order_model.dart';
import '../widgets/order_details_panel.dart';

class OrderDetailsPage extends StatefulWidget {
  const OrderDetailsPage({super.key, this.orderCode});

  final String? orderCode;

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  final _repository = OrdersRepository();

  Order? _order;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    final orderCode = widget.orderCode;
    if (orderCode == null || orderCode.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'No order code provided';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final order = await _repository.getOrderByCode(orderCode);
      if (!mounted) return;
      setState(() {
        _order = order;
        _isLoading = false;
        if (order == null) {
          _errorMessage = 'Order not found';
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = error.toString();
      });
    }
  }

  Future<void> _changeStatus(OrderStatus status) async {
    final order = _order;
    if (order == null || order.status == status) return;

    try {
      await _repository.updateOrderStatus(order.id, status);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order #${order.orderCode} marked ${status.label}'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      await _loadOrder();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update status: $error'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton.icon(
              onPressed: () => AppNav.pop(context),
              icon: const Icon(
                Icons.arrow_back,
                size: 18,
                color: AppColors.textSecondary,
              ),
              label: const Text('Back to Orders'),
            ),
            const SizedBox(height: 8),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(48),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_errorMessage != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(48),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: 16),
                      CustomText(
                        text: _errorMessage!,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySecondary,
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _loadOrder,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else if (_order != null)
              OrderDetailsPanel(order: _order!, onStatusChanged: _changeStatus),
          ],
        ),
      ),
    );
  }
}
