import '../../domain/repository/auth_repository.dart';
import '../datasource/remote/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource datasource;

  AuthRepositoryImpl(this.datasource);

  @override
  Future<UserModel> login({required String username, required String password}) async {
    return await datasource.login(username: username, password: password);
  }
}
