import 'package:dio/dio.dart';

class ErrorHandler {

  static String parseError(
      dynamic error) {

    if(error is DioException) {

      return error.response
          ?.data["message"] ??
          "Something went wrong";
    }

    return error.toString();
  }
}