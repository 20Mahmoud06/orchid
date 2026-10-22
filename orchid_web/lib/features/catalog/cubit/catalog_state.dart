import 'package:equatable/equatable.dart';

import '../../../features/choose_bouquets/models/bouquet_item.dart';
import '../../../features/choose_flowers/models/flower_item.dart';

/// State of the shared product catalog.
sealed class CatalogState extends Equatable {
  const CatalogState();

  @override
  List<Object?> get props => const <Object?>[];
}

/// Nothing has been requested yet.
final class CatalogInitial extends CatalogState {
  const CatalogInitial();
}

/// A fetch is in flight.
final class CatalogLoading extends CatalogState {
  const CatalogLoading();
}

/// A fetch failed; [error] is the raw error.
final class CatalogFailure extends CatalogState {
  const CatalogFailure(this.error);

  final Object error;

  @override
  List<Object?> get props => <Object?>[error];
}

/// The catalog is loaded and ready to display.
final class CatalogLoaded extends CatalogState {
  const CatalogLoaded({
    required this.flowers,
    required this.bouquets,
    required this.popularFlowers,
    required this.popularBouquets,
    required this.flowerCategories,
    required this.bouquetCategories,
  });

  final List<FlowerItem> flowers;
  final List<BouquetItem> bouquets;
  final List<FlowerItem> popularFlowers;
  final List<BouquetItem> popularBouquets;
  final List<String> flowerCategories;
  final List<String> bouquetCategories;

  @override
  List<Object?> get props => <Object?>[
    flowers,
    bouquets,
    popularFlowers,
    popularBouquets,
    flowerCategories,
    bouquetCategories,
  ];
}
