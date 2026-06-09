import 'package:flutter/material.dart';

import '../../data/datasource/remote/cart_remote_datasource.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/models/product_model.dart';

class CartProvider extends ChangeNotifier {
  final CartRemoteDatasource remoteDatasource;

  CartProvider(this.remoteDatasource);

  final List<CartItemModel> _items = [];

  List<CartItemModel> get items => _items;

  Future<void> addToCart(ProductModel product) async {
    final index = _items.indexWhere((e) => e.product.id == product.id);

    if (index >= 0) {
      final item = _items[index];

      _items[index] = item.copyWith(quantity: item.quantity + 1);
    } else {
      _items.add(CartItemModel(product: product, quantity: 1));
    }

    notifyListeners();

    try {
      await remoteDatasource.addToCart(
        productId: product.id,
        quantity: getProductQuantity(product.id),
      );
    } catch (_) {}
  }

  Future<void> decrementQty(ProductModel product) async {
    final index = _items.indexWhere((e) => e.product.id == product.id);

    if (index < 0) return;

    final item = _items[index];

    if (item.quantity == 1) {
      _items.removeAt(index);

      try {
        await remoteDatasource.removeFromCart(product.id);
      } catch (_) {}
    } else {
      _items[index] = item.copyWith(quantity: item.quantity - 1);

      try {
        await remoteDatasource.addToCart(productId: product.id, quantity: item.quantity - 1);
      } catch (_) {}
    }

    notifyListeners();
  }

  int getProductQuantity(int productId) {
    try {
      return _items.firstWhere((e) => e.product.id == productId).quantity;
    } catch (_) {
      return 0;
    }
  }

  Future<void> clearCart() async {
    _items.clear();

    notifyListeners();

    try {
      await remoteDatasource.clearCart();
    } catch (_) {}
  }

  double get total {
    double value = 0;

    for (final item in _items) {
      value += item.product.price * item.quantity;
    }

    return value;
  }
}
