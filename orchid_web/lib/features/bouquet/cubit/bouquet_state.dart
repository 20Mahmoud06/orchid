import 'package:equatable/equatable.dart';

/// Selected flowers/bouquets and their quantities for a custom bouquet.
class BouquetState extends Equatable {
  const BouquetState({this.quantities = const <String, int>{}});

  /// Keyed by product id.
  final Map<String, int> quantities;

  @override
  List<Object?> get props => <Object?>[quantities];
}
