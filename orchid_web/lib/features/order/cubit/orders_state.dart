import 'package:equatable/equatable.dart';

import '../models/customer_order.dart';

/// State of the signed-in customer's order history.
sealed class OrdersState extends Equatable {
  const OrdersState();

  @override
  List<Object?> get props => const <Object?>[];
}

final class OrdersInitial extends OrdersState {
  const OrdersInitial();
}

final class OrdersLoading extends OrdersState {
  const OrdersLoading();
}

final class OrdersFailure extends OrdersState {
  const OrdersFailure(this.error);

  final Object error;

  @override
  List<Object?> get props => <Object?>[error];
}

final class OrdersLoaded extends OrdersState {
  const OrdersLoaded(this.orders);

  final List<CustomerOrder> orders;

  @override
  List<Object?> get props => <Object?>[orders];
}
