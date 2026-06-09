import '../../../core/network/dio_client.dart';

class PaymentRemoteDatasource {
  Future<Map<String, dynamic>> processPayment({
    required String orderId,

    required double amount,

    required String localOrderId,

    required String paymentMode,

    required String paymentRef,

    required int serverOrderId,
  }) async {
    final response = await DioClient.dio.post(
      "/payments",

      data: {
        "amount": amount,

        "localOrderId": localOrderId,

        "paymentMode": paymentMode,

        "paymentRef": paymentRef,

        "serverOrderId": serverOrderId,
      },
    );

    return response.data;
  }

  Future<Map<String, dynamic>> getPaymentStatus(int paymentId) async {
    final response = await DioClient.dio.get("/payments/$paymentId");

    return response.data;
  }
}
