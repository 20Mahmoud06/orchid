import 'package:flutter/material.dart';
import 'package:orchid_admin/features/products/domain/models/product_model.dart';

class SelectedFlower {
  SelectedFlower(this.product) : quantity = TextEditingController(text: '1');

  final Product product;
  final TextEditingController quantity;

  void dispose() => quantity.dispose();
}
