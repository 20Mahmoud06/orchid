import 'package:equatable/equatable.dart';

/// Ids of the products the customer has marked as favorite.
class FavoritesState extends Equatable {
  const FavoritesState({
    this.flowerIds = const <String>{},
    this.bouquetIds = const <String>{},
  });

  final Set<String> flowerIds;
  final Set<String> bouquetIds;

  @override
  List<Object?> get props => <Object?>[flowerIds, bouquetIds];
}
