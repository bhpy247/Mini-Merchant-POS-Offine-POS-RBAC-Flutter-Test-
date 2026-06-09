import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/services/connectivity_service.dart';

class ConnectivityProvider extends ChangeNotifier {
  bool isConnected = true;

  StreamSubscription? _subscription;

  ConnectivityProvider() {
    init();
  }

  void init() {
    _subscription = ConnectivityService.connectionStream.listen((event) {
      isConnected = event;

      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();

    super.dispose();
  }
}
