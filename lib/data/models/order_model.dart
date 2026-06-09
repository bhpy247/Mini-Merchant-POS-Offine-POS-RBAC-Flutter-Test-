import '../../core/constants/app_enums.dart';
import '../../core/constants/parsing_helper.dart';
import 'cart_item_model.dart';

class OrderModel {
  final String localOrderId;

  final List<CartItemModel> items;

  final double total;

  final String paymentMode;

  final String paymentStatus;

  final SyncStatus syncStatus;

  final DateTime createdAt;

  OrderModel({
    required this.localOrderId,
    required this.items,
    required this.total,
    required this.paymentMode,
    required this.paymentStatus,
    required this.syncStatus,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      localOrderId: ParsingHelper.parseStringMethod(json['localOrderId']),

      items: ParsingHelper.parseListMethod<dynamic, dynamic>(json['items']).map((e) {
        return CartItemModel.fromJson(e);
      }).toList(),

      total: ParsingHelper.parseDoubleMethod(json['total']),

      paymentMode: ParsingHelper.parseStringMethod(json['paymentMode']),

      paymentStatus: ParsingHelper.parseStringMethod(json['paymentStatus']),

      syncStatus: SyncStatus.values.firstWhere(
        (e) => e.name == json['syncStatus'],
        orElse: () => SyncStatus.pending,
      ),

      createdAt:
          DateTime.tryParse(ParsingHelper.parseStringMethod(json['createdAt'])) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "localOrderId": localOrderId,

      "items": items.map((e) => e.toJson()).toList(),

      "total": total,

      "paymentMode": paymentMode,

      "paymentStatus": paymentStatus,

      "syncStatus": syncStatus.name,

      "createdAt": createdAt.toIso8601String(),
    };
  }

  OrderModel copyWith({
    String? localOrderId,
    List<CartItemModel>? items,
    double? total,
    String? paymentMode,
    String? paymentStatus,
    SyncStatus? syncStatus,
    DateTime? createdAt,
  }) {
    return OrderModel(
      localOrderId: localOrderId ?? this.localOrderId,

      items: items ?? this.items,

      total: total ?? this.total,

      paymentMode: paymentMode ?? this.paymentMode,

      paymentStatus: paymentStatus ?? this.paymentStatus,

      syncStatus: syncStatus ?? this.syncStatus,

      createdAt: createdAt ?? this.createdAt,
    );
  }
}
