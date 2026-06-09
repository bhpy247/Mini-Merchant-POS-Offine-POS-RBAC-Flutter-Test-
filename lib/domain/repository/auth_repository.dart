import '../../data/models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel> login({required String username, required String password});
}
