/// One line of the order being placed, in the shape the order summary renders:
/// a photo, a name, the composition/message and the line price.
class CheckoutLineItem {
  const CheckoutLineItem({
    required this.name,
    required this.image,
    required this.description,
    required this.price,
    required this.quantity,
  });

  final String name;
  final String image;
  final String description;
  final int price;
  final int quantity;
}
