/// Raised when an order cannot be placed; [message] is safe to show to the
/// user.
class CheckoutException implements Exception {
  CheckoutException(this.message);

  final String message;

  @override
  String toString() => message;
}
