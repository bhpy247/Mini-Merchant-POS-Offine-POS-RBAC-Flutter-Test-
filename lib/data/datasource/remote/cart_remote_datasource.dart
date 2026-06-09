import '../../../core/network/dio_client.dart';

class CartRemoteDatasource {
  Future<void> addToCart({required int productId, required int quantity}) async {
    await DioClient.dio.post("/cart/items", data: {"product_id": productId, "quantity": quantity});
  }

  Future<void> removeFromCart(int productId) async {
    await DioClient.dio.delete("/cart/items/$productId");
  }

  Future<void> clearCart() async {
    await DioClient.dio.delete("/cart/clear");
  }

  Future<dynamic> getCart() async {
    final response = await DioClient.dio.get("/cart");

    return response.data;
  }
}
