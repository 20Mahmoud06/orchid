import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../features/choose_bouquets/models/bouquet_item.dart';
import '../../../features/choose_flowers/models/flower_item.dart';
import '../../../core/app_keys.dart';
import '../../catalog/cubit/catalog_cubit.dart';
import '../../../core/storage/local_storage.dart';
import 'favorites_state.dart';

/// Shared favorites state across choose flowers, choose bouquets and the
/// favorites screen.
class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit() : super(const FavoritesState());

  static final FavoritesCubit instance = FavoritesCubit();

  /// Restores the favorites saved on this device. Call once from `main`.
  Future<void> init() async {
    final flowerIds = _decodeIds(
      await AppPrefs.instance.getString(AppPrefKeys.favoriteFlowerIds),
    );
    final bouquetIds = _decodeIds(
      await AppPrefs.instance.getString(AppPrefKeys.favoriteBouquetIds),
    );
    emit(
      FavoritesState(
        flowerIds: flowerIds.toSet(),
        bouquetIds: bouquetIds.toSet(),
      ),
    );
  }

  static List<String> _decodeIds(String? raw) {
    if (raw == null || raw.isEmpty) return const <String>[];
    try {
      final decoded = jsonDecode(raw);
      return decoded is List
          ? decoded.whereType<String>().toList()
          : const <String>[];
    } catch (_) {
      return const <String>[];
    }
  }

  void _persist(FavoritesState next) {
    AppPrefs.instance
      ..saveString(
        AppPrefKeys.favoriteFlowerIds,
        jsonEncode(next.flowerIds.toList()),
      )
      ..saveString(
        AppPrefKeys.favoriteBouquetIds,
        jsonEncode(next.bouquetIds.toList()),
      );
  }

  bool isFlowerFavorite(String id) => state.flowerIds.contains(id);

  bool isBouquetFavorite(String id) => state.bouquetIds.contains(id);

  List<FlowerItem> get favoriteFlowers => CatalogCubit.instance.flowers
      .where((flower) => state.flowerIds.contains(flower.id))
      .toList();

  List<BouquetItem> get favoriteBouquets => CatalogCubit.instance.bouquets
      .where((bouquet) => state.bouquetIds.contains(bouquet.id))
      .toList();

  int get totalFavorites => state.flowerIds.length + state.bouquetIds.length;

  void toggleFlowerFavorite(String id) {
    final ids = Set<String>.of(state.flowerIds);
    if (!ids.remove(id)) ids.add(id);
    final next = FavoritesState(flowerIds: ids, bouquetIds: state.bouquetIds);
    _persist(next);
    emit(next);
  }

  void toggleBouquetFavorite(String id) {
    final ids = Set<String>.of(state.bouquetIds);
    if (!ids.remove(id)) ids.add(id);
    final next = FavoritesState(flowerIds: state.flowerIds, bouquetIds: ids);
    _persist(next);
    emit(next);
  }
}
