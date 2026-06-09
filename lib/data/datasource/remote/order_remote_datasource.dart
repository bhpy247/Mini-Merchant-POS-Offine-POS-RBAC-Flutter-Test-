import '../../../core/network/dio_client.dart';
import '../../models/order_model.dart';

class OrderRemoteDatasource {
  Future<void> syncOrder(OrderModel order) async {
    await DioClient.dio.post(
      "/orders",

      data: {
        "localOrderId": order.localOrderId,

        "items": order.items.map((e) {
          return {"productId": e.product.id, "quantity": e.quantity};
        }).toList(),

        "paymentMode": order.paymentMode,

        "paymentStatus": order.paymentStatus,

        "total": order.total,
      },
    );
  }
}
