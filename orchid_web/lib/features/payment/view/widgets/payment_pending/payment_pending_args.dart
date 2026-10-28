import 'package:flutter/material.dart';

/// Arguments for the card-payment status screen.
class PaymentPendingArgs {
  const PaymentPendingArgs({required this.orderId, required this.orderCode});

  final String orderId;
  final String orderCode;

  String get displayCode => orderCode.isEmpty ? '' : '#$orderCode';
}
