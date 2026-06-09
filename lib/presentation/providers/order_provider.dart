import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_enums.dart';
import '../../core/services/hive_service.dart';
import '../../data/datasource/remote/order_remote_datasource.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/models/order_model.dart';

class OrderProvider extends ChangeNotifier {
  final OrderRemoteDatasource remoteDatasource;

  OrderProvider(this.remoteDatasource);

  List<OrderModel> orders = [];

  bool isSyncing = false;

  Future<void> createOrder({required List<CartItemModel> items, required double total}) async {
    final order = OrderModel(
      localOrderId: const Uuid().v4(),

      items: items,

      total: total,

      paymentMode: "Cash",

      paymentStatus: "SUCCESS",

      syncStatus: SyncStatus.pending,

      createdAt: DateTime.now(),
    );

    final box = HiveService.getOrderBox();

    await box.put(order.localOrderId, jsonEncode(order.toJson()));

    await loadOrders();
  }

  Future<void> loadOrders() async {
    final box = HiveService.getOrderBox();

    orders = [];

    for (final value in box.values) {
      final order = OrderModel.fromJson(jsonDecode(value));

      orders.add(order);
    }

    orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    notifyListeners();
  }

  Future<void> updateOrder(OrderModel order) async {
    final box = HiveService.getOrderBox();

    await box.put(order.localOrderId, jsonEncode(order.toJson()));

    await loadOrders();
  }

  Future<void> syncPendingOrders() async {
    if (isSyncing) return;

    try {
      isSyncing = true;

      notifyListeners();

      await loadOrders();

      for (final order in orders) {
        if (order.syncStatus == SyncStatus.synced) {
          continue;
        }

        try {
          final paidOrder = order.copyWith(syncStatus: SyncStatus.paid);

          await updateOrder(paidOrder);

          await remoteDatasource.syncOrder(paidOrder);

          final syncedOrder = paidOrder.copyWith(syncStatus: SyncStatus.synced);

          await updateOrder(syncedOrder);
        } catch (e) {
          final failedOrder = order.copyWith(syncStatus: SyncStatus.failed);

          await updateOrder(failedOrder);
        }
      }
    } finally {
      isSyncing = false;

      notifyListeners();
    }
  }

  Future<void> retryFailedOrders() async {
    await loadOrders();

    for (final order in orders) {
      if (order.syncStatus == SyncStatus.failed) {
        try {
          final retryOrder = order.copyWith(syncStatus: SyncStatus.pending);

          await updateOrder(retryOrder);
        } catch (_) {}
      }
    }

    await syncPendingOrders();
  }
}
