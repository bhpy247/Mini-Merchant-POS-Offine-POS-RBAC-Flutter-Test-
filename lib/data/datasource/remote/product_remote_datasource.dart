import '../../../core/constants/api_constants.dart';
import '../../../core/constants/my_print.dart';
import '../../../core/network/dio_client.dart';
import '../../models/product_model.dart';

class ProductRemoteDatasource {
  Future<List<ProductModel>> getProducts() async {
    MyPrint.printOnConsole("getProducts ${DioClient.dio.options.baseUrl}");

    final response = await DioClient.dio.get("${ApiConstants.baseUrl}/products");

    final data = response.data as List;

    MyPrint.printOnConsole("data : $data");

    return data.map((e) => ProductModel.fromJson(e)).toList();
  }
}
