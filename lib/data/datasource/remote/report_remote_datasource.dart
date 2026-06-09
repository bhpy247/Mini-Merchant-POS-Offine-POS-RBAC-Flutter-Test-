import '../../../core/network/dio_client.dart';

class ReportsRemoteDatasource {
  Future<dynamic> getTodaySales() async {
    final response = await DioClient.dio.get("/reports/today-sales");

    return response.data;
  }

  Future<dynamic> getPendingSync() async {
    final response = await DioClient.dio.get("/reports/pending-sync");

    return response.data;
  }
}
