import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final Connectivity _connectivity = Connectivity();

  static Stream<bool> get connectionStream {
    return _connectivity.onConnectivityChanged.map((result) => result != ConnectivityResult.none);
  }
}
