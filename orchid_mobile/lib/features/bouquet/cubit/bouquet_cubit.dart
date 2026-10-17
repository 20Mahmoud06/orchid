import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../features/choose_bouquets/models/bouquet_item.dart';
import '../../../features/choose_flowers/models/flower_item.dart';
import '../../../shared/widgets/custom_text.dart';
import '../../../core/app_keys.dart';
import '../../catalog/cubit/catalog_cubit.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/storage/local_storage.dart';
import 'bouquet_state.dart';

/// Shared bouquet selection state across choose flowers and your bouquet
/// screens.
class BouquetCubit extends Cubit<BouquetState> {
  BouquetCubit() : super(const BouquetState());

  static final BouquetCubit instance = BouquetCubit();

  /// A bouquet can contain at most [maxFlowers] flowers in total.
  static const int maxFlowers = 15;

  /// A bouquet can contain at most [maxFlowerKinds] different kinds of flowers.
  static const int maxFlowerKinds = 7;

  /// Restores the bouquet selections saved on this device. Call once from
  /// `main`.
  Future<void> init() async {
    final raw =
        await AppPrefs.instance.getString(AppPrefKeys.bouquetQuantities);
    emit(BouquetState(quantities: _decodeQuantities(raw)));
  }

  static Map<String, int> _decodeQuantities(String? raw) {
    if (raw == null || raw.isEmpty) return <String, int>{};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return <String, int>{};
      return decoded
          .map(
            (key, value) =>
                MapEntry(key.toString(), (value as num?)?.toInt() ?? 0),
          )
          ..removeWhere((_, quantity) => quantity <= 0);
    } catch (_) {
      return <String, int>{};
    }
  }

  void _persist(Map<String, int> quantities) {
    AppPrefs.instance
        .saveString(AppPrefKeys.bouquetQuantities, jsonEncode(quantities));
  }

  int getQuantity(String flowerId) => state.quantities[flowerId] ?? 0;

  /// Only flowers that still exist in the live catalog are counted, so a
  /// persisted selection for a product that was deleted in the admin never
  /// inflates the totals or blocks the bouquet limits.
  int get totalCount => selectedFlowers.fold(
        0,
        (sum, flower) => sum + getQuantity(flower.id),
      );

  int get distinctKindsCount => selectedFlowers.length;

  int get totalPrice {
    var total = 0;
    for (final flower in CatalogCubit.instance.flowers) {
      total += flower.price * getQuantity(flower.id);
    }
    for (final bouquet in CatalogCubit.instance.bouquets) {
      total += bouquet.price * getQuantity(bouquet.id);
    }
    return total;
  }

  List<FlowerItem> get selectedFlowers => CatalogCubit.instance.flowers
      .where((flower) => getQuantity(flower.id) > 0)
      .toList();

  /// Ready bouquets picked on the choose bouquets screen; they share the
  /// same quantity map (and limits) as the flowers.
  List<BouquetItem> get selectedReadyBouquets => CatalogCubit.instance.bouquets
      .where((bouquet) => getQuantity(bouquet.id) > 0)
      .toList();

  String get descriptionText {
    final parts = <String>[
      for (final flower in selectedFlowers)
        '${getQuantity(flower.id)} ${flower.name.toLowerCase()}',
      for (final bouquet in selectedReadyBouquets)
        '${getQuantity(bouquet.id)} ${bouquet.name.toLowerCase()}',
    ];

    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first;
    if (parts.length == 2) return '${parts.first} and ${parts.last}';

    return '${parts.sublist(0, parts.length - 1).join(', ')} and ${parts.last}';
  }

  void incrementQuantity(String flowerId) {
    final current = getQuantity(flowerId);

    // Adding a kind of flower that is not part of the bouquet yet.
    if (current == 0 && distinctKindsCount >= maxFlowerKinds) {
      _showMessage(
        'you can add up to $maxFlowerKinds different kinds of flowers',
      );
      return;
    }

    // Reached the maximum total number of flowers.
    if (totalCount >= maxFlowers) {
      _showMessage('your bouquet can contain up to $maxFlowers flowers');
      return;
    }

    final quantities = Map<String, int>.of(state.quantities)
      ..[flowerId] = current + 1;
    _persist(quantities);
    emit(BouquetState(quantities: quantities));
  }

  void decrementQuantity(String flowerId) {
    final current = getQuantity(flowerId);
    final quantities = Map<String, int>.of(state.quantities);
    if (current <= 1) {
      quantities.remove(flowerId);
    } else {
      quantities[flowerId] = current - 1;
    }
    _persist(quantities);
    emit(BouquetState(quantities: quantities));
  }

  /// Empties the bouquet after the order has been placed.
  void clear() {
    _persist(const <String, int>{});
    emit(const BouquetState());
  }

  /// Drops the selected ready bouquets from the selection, leaving the custom
  /// flowers untouched. Used once the ready bouquets have been moved to the
  /// cart.
  void clearReadyBouquets() {
    final readyIds = selectedReadyBouquets.map((bouquet) => bouquet.id).toSet();
    if (readyIds.isEmpty) return;
    final quantities = Map<String, int>.of(state.quantities)
      ..removeWhere((id, _) => readyIds.contains(id));
    _persist(quantities);
    emit(BouquetState(quantities: quantities));
  }

  void _showMessage(String message) {
    final messenger = scaffoldMessengerKey.currentState;
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.darkGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          content: CustomText(
            text: message,
            fontFamily: AppFonts.inriaSerif,
            fontSize: 14.sp,
            textColor: AppColors.white,
          ),
        ),
      );
  }
}
