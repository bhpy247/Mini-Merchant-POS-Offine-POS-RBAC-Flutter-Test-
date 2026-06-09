import 'package:flutter/material.dart';

import '../../data/datasource/remote/report_remote_datasource.dart';

class ReportsProvider extends ChangeNotifier {
  final ReportsRemoteDatasource remoteDatasource;

  ReportsProvider(this.remoteDatasource);

  bool isLoading = false;

  int totalOrders = 0;

  double totalRevenue = 0;

  int pendingSync = 0;

  Future<void> loadReports() async {
    try {
      isLoading = true;

      notifyListeners();

      final salesResponse = await remoteDatasource.getTodaySales();

      final pendingResponse = await remoteDatasource.getPendingSync();

      totalOrders = salesResponse["totalOrders"] ?? 0;

      totalRevenue = (salesResponse["totalAmount"] as num?)?.toDouble() ?? 0;

      pendingSync = pendingResponse["pendingOrders"] ?? 0;
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading = false;

      notifyListeners();
    }
  }
}
