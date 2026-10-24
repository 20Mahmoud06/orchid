import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../features/choose_bouquets/models/bouquet_item.dart';
import '../../../features/choose_flowers/models/flower_item.dart';
import 'catalog_state.dart';

/// Live product catalog backed by the same `products` table the admin
/// dashboard writes to.
///
/// `type = flower` rows feed the choose flowers screen, `type = ready_bouquet`
/// rows the choose bouquets screen, and the joined `categories.name` powers
/// the category tabs — so a product created in the admin shows up here in the
/// right list, under the right category.
class CatalogCubit extends Cubit<CatalogState> {
  CatalogCubit() : super(const CatalogInitial());

  static final CatalogCubit instance = CatalogCubit();

  /// Replaces the catalog with [state] without a network fetch — used by
  /// widget tests to render catalog-backed screens deterministically.
  @visibleForTesting
  void seed(CatalogLoaded state) => emit(state);

  static const String _bucket = 'product-images';
  static const String _allFlowersTab = 'All flowers';
  static const String _allBouquetsTab = 'All bouquets';
  static const String _uncategorised = 'more';

  /// How many items the Home "Popular" rows show.
  static const int popularCount = 5;

  CatalogLoaded? get _loaded =>
      state is CatalogLoaded ? state as CatalogLoaded : null;

  /// Active flowers (type `flower`), newest first.
  List<FlowerItem> get flowers => _loaded?.flowers ?? const <FlowerItem>[];

  /// Active ready bouquets (type `ready_bouquet`), newest first.
  List<BouquetItem> get bouquets => _loaded?.bouquets ?? const <BouquetItem>[];

  /// Random picks for the Home screen, chosen once per load so the "Popular"
  /// rows change every time the app is opened.
  List<FlowerItem> get popularFlowers =>
      _loaded?.popularFlowers ?? const <FlowerItem>[];

  List<BouquetItem> get popularBouquets =>
      _loaded?.popularBouquets ?? const <BouquetItem>[];

  /// Choose-flowers tabs: `All flowers` plus every category present on the
  /// active flowers, alphabetically.
  List<String> get flowerCategories =>
      _loaded?.flowerCategories ?? const <String>[_allFlowersTab];

  /// Choose-bouquets tabs, built the same way from the ready bouquets.
  List<String> get bouquetCategories =>
      _loaded?.bouquetCategories ?? const <String>[_allBouquetsTab];

  bool get isLoaded => state is CatalogLoaded;

  bool get isLoading => state is CatalogLoading;

  Object? get error =>
      state is CatalogFailure ? (state as CatalogFailure).error : null;

  /// Fetches the active catalog. Safe to call from every screen: the first
  /// call fetches, later calls are no-ops unless [force] re-fetches.
  Future<void> load({bool force = false}) async {
    if (state is CatalogLoading || (state is CatalogLoaded && !force)) return;
    // Deferred so calls made from `initState` never emit in the middle of a
    // build.
    await Future<void>.microtask(() {});
    if (state is CatalogLoading || (state is CatalogLoaded && !force)) return;

    emit(const CatalogLoading());
    try {
      final rows = await Supabase.instance.client
          .from('products')
          .select('id, name, price, type, image_path, categories(name)')
          .eq('is_active', true)
          .order('created_at', ascending: false);

      final flowers = <FlowerItem>[];
      final bouquets = <BouquetItem>[];
      for (final row in rows) {
        if (row['type'] == 'ready_bouquet') {
          bouquets.add(_toBouquet(row));
        } else {
          flowers.add(_toFlower(row));
        }
      }
      emit(
        CatalogLoaded(
          flowers: flowers,
          bouquets: bouquets,
          popularFlowers: _pickPopular(flowers),
          popularBouquets: _pickPopular(bouquets),
          flowerCategories: _tabsFor(
            flowers.map((flower) => flower.category),
            _allFlowersTab,
          ),
          bouquetCategories: _tabsFor(
            bouquets.map((bouquet) => bouquet.category),
            _allBouquetsTab,
          ),
        ),
      );
    } catch (e) {
      emit(CatalogFailure(e));
    }
  }

  FlowerItem _toFlower(Map<String, dynamic> row) {
    final item = _base(row);
    return FlowerItem(
      id: item.id,
      name: item.name,
      price: item.price,
      category: item.category,
      imagePath: item.imagePath,
    );
  }

  BouquetItem _toBouquet(Map<String, dynamic> row) {
    final item = _base(row);
    return BouquetItem(
      id: item.id,
      name: item.name,
      price: item.price,
      category: item.category,
      imagePath: item.imagePath,
    );
  }

  ({String id, String name, int price, String category, String imagePath})
  _base(Map<String, dynamic> row) {
    final name = (row['name'] as String? ?? '').trim();
    final joined = row['categories'];
    final categoryName = joined is Map
        ? (joined['name'] as String?)?.trim()
        : null;
    return (
      id: row['id'] as String,
      name: name.isEmpty ? 'Untitled' : name,
      price: ((row['price'] as num?) ?? 0).round(),
      category: (categoryName == null || categoryName.isEmpty)
          ? _uncategorised
          : categoryName,
      imagePath: _imageUrl(row['image_path'] as String? ?? ''),
    );
  }

  String _imageUrl(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return Supabase.instance.client.storage.from(_bucket).getPublicUrl(path);
  }

  List<T> _pickPopular<T>(List<T> source) {
    final shuffled = List<T>.of(source)..shuffle(Random());
    return shuffled.take(popularCount).toList();
  }

  List<String> _tabsFor(Iterable<String> rawCategories, String allLabel) {
    final seen = <String>{};
    final categories = <String>[];
    for (final category in rawCategories) {
      if (seen.add(category.toLowerCase())) {
        categories.add(category);
      }
    }
    final more = categories
        .where((category) => category.toLowerCase() == _uncategorised)
        .toList();
    categories
      ..removeWhere((category) => category.toLowerCase() == _uncategorised)
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return <String>[allLabel, ...categories, ...more];
  }
}
