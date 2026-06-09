import '../../../core/network/dio_client.dart';

class PaymentRemoteDatasource {
  Future<Map<String, dynamic>> processPayment({
    required String orderId,

    required double amount,

    required String localOrderId,
  }) async {
    final response = await DioClient.dio.post(
      "/payments",

      data: {"order_id": orderId, "amount": amount, "localOrderId": localOrderId},
    );

    return response.data;
  }
}
