import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_enums.dart';
import '../../core/constants/parsing_helper.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/services/hive_service.dart';
import '../../data/datasource/remote/order_remote_datasource.dart';
import '../../data/datasource/remote/payment_remote_datasource.dart';
import '../../data/datasource/remote/sync_remote_datasource.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/models/order_model.dart';

class OrderProvider extends ChangeNotifier {
  final OrderRemoteDatasource remoteDatasource;

  final PaymentRemoteDatasource paymentDatasource;

  final SyncRemoteDatasource syncDatasource;

  OrderProvider(this.remoteDatasource, this.paymentDatasource, this.syncDatasource);

  List<OrderModel> orders = [];

  bool isLoading = false;

  bool isSyncing = false;

  /// LOAD ORDERS

  Future<void> loadOrders() async {
    try {
      final box = HiveService.getOrderBox();

      orders = [];

      for (final value in box.values) {
        final order = OrderModel.fromJson(jsonDecode(value));

        orders.add(order);
      }

      orders.sort((a, b) {
        return b.createdAt.compareTo(a.createdAt);
      });

      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// UPDATE ORDER

  Future<void> updateOrder(OrderModel order) async {
    try {
      final box = HiveService.getOrderBox();

      await box.put(order.localOrderId, jsonEncode(order.toJson()));

      final index = orders.indexWhere((e) {
        return e.localOrderId == order.localOrderId;
      });

      if (index >= 0) {
        orders[index] = order;
      } else {
        orders.add(order);
      }

      orders.sort((a, b) {
        return b.createdAt.compareTo(a.createdAt);
      });

      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// CREATE ORDER ENTRY POINT

  Future<OrderModel> createOrder({required List<CartItemModel> items, required double total}) async {
    final connected = await ConnectivityService.isConnected();

    if (connected) {
      return await createOnlineOrder(items: items, total: total);
    } else {
      return await createOfflineOrder(items: items, total: total);
    }
  }

  /// ONLINE ORDER

  Future<OrderModel> createOnlineOrder({required List<CartItemModel> items, required double total}) async {
    final localOrderId = const Uuid().v4();

    final order = OrderModel(
      localOrderId: localOrderId,

      serverOrderId: 0,

      items: items,

      total: total,

      paymentMode: "",

      paymentStatus: "PENDING",

      paymentRef: "",

      syncStatus: SyncStatus.pending,

      createdAt: DateTime.now(),
    );

    try {
      isLoading = true;

      notifyListeners();

      /// CREATE ORDER API

      final response = await remoteDatasource.createOrder(order);

      final serverOrderId = ParsingHelper.parseIntMethod(response["id"]);

      final createdOrder = order.copyWith(serverOrderId: serverOrderId, syncStatus: SyncStatus.orderCreated);

      await updateOrder(createdOrder);

      return createdOrder;
    } catch (e) {
      debugPrint(e.toString());

      return await createOfflineOrder(items: items, total: total);
    } finally {
      isLoading = false;

      notifyListeners();
    }
  }

  /// OFFLINE ORDER

  Future<OrderModel> createOfflineOrder({required List<CartItemModel> items, required double total}) async {
    final order = OrderModel(
      localOrderId: const Uuid().v4(),

      serverOrderId: 0,

      items: items,

      total: total,

      paymentMode: "OFFLINE",

      paymentStatus: "PENDING",

      paymentRef: "",

      syncStatus: SyncStatus.pending,

      createdAt: DateTime.now(),
    );

    await updateOrder(order);

    return order;
  }

  /// PAYMENT PROCESS

  Future<void> processPayment(OrderModel order, String paymentMode) async {
    try {
      isLoading = true;

      notifyListeners();

      final paymentRef = "txn-${DateTime.now().millisecondsSinceEpoch}";

      final response = await paymentDatasource.processPayment(
        orderId: order.serverOrderId.toString(),

        amount: order.total,

        localOrderId: order.localOrderId,

        paymentMode: paymentMode,

        paymentRef: paymentRef,

        serverOrderId: order.serverOrderId,
      );

      final updatedOrder = order.copyWith(
        paymentMode: paymentMode,

        paymentRef: ParsingHelper.parseStringMethod(response["paymentRef"]),

        paymentStatus: ParsingHelper.parseStringMethod(response["status"]),

        syncStatus: SyncStatus.synced,
      );

      await updateOrder(updatedOrder);
    } catch (e) {
      debugPrint(e.toString());

      final failedOrder = order.copyWith(syncStatus: SyncStatus.failed);

      await updateOrder(failedOrder);

      rethrow;
    } finally {
      isLoading = false;

      notifyListeners();
    }
  }

  /// SYNC OFFLINE ORDERS

  Future<void> syncOfflineOrders() async {
    if (isSyncing) return;

    try {
      isSyncing = true;

      notifyListeners();

      await loadOrders();

      final offlineOrders = orders.where((e) {
        return e.serverOrderId == 0;
      }).toList();

      if (offlineOrders.isEmpty) {
        return;
      }

      /// STEP 1
      /// SYNC ORDERS

      await syncDatasource.syncOrders(offlineOrders);

      /// STEP 2
      /// PROCESS PAYMENTS

      for (final order in offlineOrders) {
        try {
          final paymentRef = "txn-${DateTime.now().millisecondsSinceEpoch}";

          final response = await paymentDatasource.processPayment(
            orderId: order.localOrderId,

            amount: order.total,

            localOrderId: order.localOrderId,

            paymentMode: "OFFLINE",

            paymentRef: paymentRef,

            serverOrderId: 0,
          );

          final paidOrder = order.copyWith(
            paymentMode: "OFFLINE",

            paymentRef: ParsingHelper.parseStringMethod(response["paymentRef"]),

            paymentStatus: ParsingHelper.parseStringMethod(response["status"]),

            syncStatus: SyncStatus.paid,
          );

          await updateOrder(paidOrder);
        } catch (e) {
          final failedOrder = order.copyWith(syncStatus: SyncStatus.failed);

          await updateOrder(failedOrder);
        }
      }

      /// RELOAD

      await loadOrders();

      final paidOrders = orders.where((e) {
        return e.syncStatus == SyncStatus.paid;
      }).toList();

      if (paidOrders.isEmpty) {
        return;
      }

      /// STEP 3
      /// SYNC PAYMENTS

      await syncDatasource.syncPayments(paidOrders);

      /// STEP 4
      /// MARK SYNCED

      for (final order in paidOrders) {
        final syncedOrder = order.copyWith(syncStatus: SyncStatus.synced);

        await updateOrder(syncedOrder);
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isSyncing = false;

      notifyListeners();
    }
  }

  /// RETRY FAILED ORDERS

  Future<void> retryFailedOrders() async {
    await loadOrders();

    final failedOrders = orders.where((e) {
      return e.syncStatus == SyncStatus.failed;
    }).toList();

    for (final order in failedOrders) {
      final pendingOrder = order.copyWith(syncStatus: SyncStatus.pending);

      await updateOrder(pendingOrder);
    }

    await syncOfflineOrders();
  }
}
