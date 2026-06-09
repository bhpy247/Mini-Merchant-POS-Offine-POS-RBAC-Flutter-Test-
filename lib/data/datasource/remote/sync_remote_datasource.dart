import '../../../core/network/dio_client.dart';
import '../../models/order_model.dart';

class SyncRemoteDatasource {
  Future<void> syncOrders(List<OrderModel> orders) async {
    await DioClient.dio.post(
      "/sync/orders",

      data: {
        "orders": orders.map((order) {
          return {
            "localOrderId": order.localOrderId,

            "paymentMode": order.paymentMode,

            "paymentStatus": order.paymentStatus,

            "totalAmount": order.total,

            "items": order.items.map((e) {
              return {"productId": e.product.id, "qty": e.quantity, "price": e.product.price};
            }).toList(),
          };
        }).toList(),
      },
    );
  }

  Future<void> syncPayments(List<OrderModel> orders) async {
    await DioClient.dio.post(
      "/sync/payments",

      data: {
        "payments": orders.map((order) {
          return {"paymentRef": order.paymentRef, "status": order.paymentStatus};
        }).toList(),
      },
    );
  }
}
