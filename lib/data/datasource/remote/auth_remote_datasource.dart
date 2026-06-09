import 'package:dio/dio.dart';
import 'package:minipostest/core/constants/api_constants.dart';

import '../../../core/network/dio_client.dart';
import '../../models/user_model.dart';

class AuthRemoteDatasource {
  Future<UserModel> login({required String username, required String password}) async {
    final response = await DioClient.dio.post(
      "${ApiConstants.baseUrl}/login",
      data: {"username": username, "password": password},
    );

    print("Respnse: $response");

    return UserModel.fromJson(response.data);
  }
}
