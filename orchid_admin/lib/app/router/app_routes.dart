class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String products = '/products';
  static const String addProduct = '/products/add';
  static const String orders = '/orders';
  static const String inspiration = '/inspiration';
  static const String addInspiration = '/inspiration/add';

  static String editProduct(String productId) => '/products/$productId/edit';

  static String orderDetails(String orderCode) => '/orders/$orderCode';
}
