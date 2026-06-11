import '../../../core/network/dio_client.dart';
import '../../models/order_model.dart';

class SyncRemoteDatasource {
  /// Returns list of { "localOrderId": "...", "id": 123 }
  /// so the provider can map local → server IDs.
  Future<List<Map<String, dynamic>>> syncOrders(List<OrderModel> orders) async {
    final response = await DioClient.dio.post(
      "/sync/orders",
      data: {
        "orders": orders.map((order) {
          return {
            "localOrderId": order.localOrderId,
            "paymentMode": order.paymentMode,
            "paymentStatus": order.paymentStatus,
            "totalAmount": order.total,
            "items": order.items.map((e) {
              return {
                "productId": e.product.id,
                "qty": e.quantity,
                "price": e.product.price,
              };
            }).toList(),
          };
        }).toList(),
      },
    );

    // Expects: { "orders": [ { "localOrderId": "...", "id": 123 }, ... ] }
    final list = response.data["orders"];
    if (list == null) return [];
    return List<Map<String, dynamic>>.from(list);
  }

  Future<void> syncPayments(List<OrderModel> orders) async {
    await DioClient.dio.post(
      "/sync/payments",
      data: {
        "payments": orders.map((order) {
          return {
            "localOrderId": order.localOrderId,   // ✅ so server can match
            "serverOrderId": order.serverOrderId, // ✅ server order reference
            "paymentRef": order.paymentRef,
            "status": order.paymentStatus,
            "amount": order.total,                // ✅ was missing
            "paymentMode": order.paymentMode,     // ✅ was missing
          };
        }).toList(),
      },
    );
  }
}