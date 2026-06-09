import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import 'dio_interceptor.dart';

class DioClient {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,

      connectTimeout: const Duration(seconds: 30),

      receiveTimeout: const Duration(seconds: 30),
    ),
  )..interceptors.add(DioInterceptor());
}
