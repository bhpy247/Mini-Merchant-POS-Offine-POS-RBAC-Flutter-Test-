import 'package:flutter/material.dart';

class SnackbarHelper {

  static void showSuccess({
    required BuildContext context,
    required String message,
  }) {

    ScaffoldMessenger.of(context)
        .showSnackBar(

      SnackBar(

        content: Text(message),

        backgroundColor:
        Colors.green,
      ),
    );
  }

  static void showError({
    required BuildContext context,
    required String message,
  }) {

    ScaffoldMessenger.of(context)
        .showSnackBar(

      SnackBar(

        content: Text(message),

        backgroundColor:
        Colors.red,
      ),
    );
  }

  static void showInfo({
    required BuildContext context,
    required String message,
  }) {

    ScaffoldMessenger.of(context)
        .showSnackBar(

      SnackBar(

        content: Text(message),

        backgroundColor:
        Colors.blue,
      ),
    );
  }
}