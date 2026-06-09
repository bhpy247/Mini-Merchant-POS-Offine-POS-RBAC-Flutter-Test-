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
  final String paymentRef;
  final int serverOrderId;

  OrderModel({
    required this.localOrderId,
    required this.items,
    required this.total,
    required this.paymentMode,
    required this.paymentStatus,
    required this.syncStatus,
    required this.createdAt,
    required this.paymentRef,
    required this.serverOrderId,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      localOrderId: ParsingHelper.parseStringMethod(json['localOrderId']),
      paymentRef: ParsingHelper.parseStringMethod(json['paymentRef']),
      serverOrderId: ParsingHelper.parseIntMethod(json['serverOrderId']),
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

      createdAt: DateTime.tryParse(ParsingHelper.parseStringMethod(json['createdAt'])) ?? DateTime.now(),
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
      "paymentRef": paymentRef,
      "serverOrderId": serverOrderId,
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
    String? paymentRef,
    int? serverOrderId,
  }) {
    return OrderModel(
      localOrderId: localOrderId ?? this.localOrderId,

      items: items ?? this.items,
      paymentRef: paymentRef ?? this.paymentRef,
      total: total ?? this.total,
      serverOrderId: serverOrderId ?? this.serverOrderId,

      paymentMode: paymentMode ?? this.paymentMode,

      paymentStatus: paymentStatus ?? this.paymentStatus,

      syncStatus: syncStatus ?? this.syncStatus,

      createdAt: createdAt ?? this.createdAt,
    );
  }
}
