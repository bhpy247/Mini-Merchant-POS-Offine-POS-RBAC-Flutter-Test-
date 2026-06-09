import '../../../core/network/dio_client.dart';
import '../../models/order_model.dart';

class OrderRemoteDatasource {
  Future<Map<String, dynamic>> createOrder(OrderModel order) async {
    final response = await DioClient.dio.post(
      "/orders",

      data: {
        "localOrderId": order.localOrderId,

        "paymentMode": order.paymentMode,

        "paymentStatus": order.paymentStatus,

        "totalAmount": order.total,

        "items": order.items.map((e) {
          return {"productId": e.product.id, "qty": e.quantity, "price": e.product.price};
        }).toList(),
      },
    );

    return response.data;
  }

  Future<dynamic> getOrders() async {
    final response = await DioClient.dio.get("/orders");

    return response.data;
  }
}
