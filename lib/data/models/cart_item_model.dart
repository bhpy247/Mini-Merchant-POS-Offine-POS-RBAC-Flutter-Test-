import '../../core/constants/parsing_helper.dart';
import 'product_model.dart';

class CartItemModel {
  final ProductModel product;
  final int quantity;

  CartItemModel({required this.product, required this.quantity});

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      product: ProductModel.fromJson(ParsingHelper.parseMapMethod(json['product'])),

      quantity: ParsingHelper.parseIntMethod(json['quantity']),
    );
  }

  Map<String, dynamic> toJson() {
    return {"product": product.toJson(), "quantity": quantity};
  }

  CartItemModel copyWith({ProductModel? product, int? quantity}) {
    return CartItemModel(product: product ?? this.product, quantity: quantity ?? this.quantity);
  }
}
