import 'package:flutter/material.dart';

import '../../data/models/product_model.dart';
import '../../domain/repository/product_repository.dart';

class ProductProvider extends ChangeNotifier {
  final ProductRepository repository;

  ProductProvider(this.repository);

  bool isLoading = false;

  List<ProductModel> products = [];

  Future<void> getProducts() async {
    try {
      isLoading = true;
      notifyListeners();

      products = await repository.getProducts();
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
