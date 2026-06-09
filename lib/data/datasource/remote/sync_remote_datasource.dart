import '../../../core/network/dio_client.dart';

class SyncRemoteDatasource {
  Future<void> syncOrders(List<Map<String, dynamic>> orders) async {
    await DioClient.dio.post("/sync/orders", data: {"orders": orders});
  }

  Future<void> syncPayments(List<Map<String, dynamic>> payments) async {
    await DioClient.dio.post("/sync/payments", data: {"payments": payments});
  }
}
