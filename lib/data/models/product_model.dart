import '../../core/constants/parsing_helper.dart';

class ProductModel {
  final int id;
  final String name;
  final double price;
  final int stock;

  ProductModel({required this.id, required this.name, required this.price, required this.stock});

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: ParsingHelper.parseIntMethod(json['id']),

      name: ParsingHelper.parseStringMethod(json['name']),

      price: ParsingHelper.parseDoubleMethod(json['price']),

      stock: ParsingHelper.parseIntMethod(json['stock']),
    );
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "name": name, "price": price, "stock": stock};
  }

  ProductModel copyWith({int? id, String? name, double? price, int? stock}) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
    );
  }
}
