import '../../domain/repository/product_repository.dart';
import '../datasource/remote/product_remote_datasource.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDatasource datasource;

  ProductRepositoryImpl(this.datasource);

  @override
  Future<List<ProductModel>> getProducts() async {
    return await datasource.getProducts();
  }
}
