import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final Connectivity _connectivity = Connectivity();

  static Stream<bool> get connectionStream {
    return _connectivity.onConnectivityChanged.map((event) {
      return event != ConnectivityResult.none;
    });
  }

  static Future<bool> isConnected() async {
    final result = await _connectivity.checkConnectivity();

    return result != ConnectivityResult.none;
  }
}
