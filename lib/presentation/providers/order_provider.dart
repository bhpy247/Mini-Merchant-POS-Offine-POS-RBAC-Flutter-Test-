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
      retryCount: 0,

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
      retryCount: 0,

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

      final offlineOrders = orders
          .where((e) => e.serverOrderId == 0 && e.syncStatus != SyncStatus.failed)
          .toList();

      if (offlineOrders.isEmpty) return;

      // ─────────────────────────────────────────────────────────
      // STEP 1 — Sync orders to server & capture returned IDs
      // ─────────────────────────────────────────────────────────
      List<Map<String, dynamic>> syncedData = [];

      try {
        syncedData = await syncDatasource.syncOrders(offlineOrders);
      } catch (e) {
        debugPrint("❌ syncOrders failed: $e");
        // Mark all as failed so they don't loop endlessly
        for (final order in offlineOrders) {
          await updateOrder(order.copyWith(syncStatus: SyncStatus.failed));
        }
        return;
      }

      // Build localOrderId → serverOrderId map from response
      final serverIdMap = <String, int>{};
      for (final item in syncedData) {
        final localId = item["localOrderId"] as String?;
        final serverId = item["id"];
        if (localId != null && serverId != null) {
          serverIdMap[localId] = (serverId is int)
              ? serverId
              : int.tryParse(serverId.toString()) ?? 0;
        }
      }

      // Persist the server IDs we just received
      for (final order in offlineOrders) {
        final serverOrderId = serverIdMap[order.localOrderId] ?? 0;
        if (serverOrderId != 0) {
          await updateOrder(
            order.copyWith(
              serverOrderId: serverOrderId,
              syncStatus: SyncStatus.orderCreated,
            ),
          );
        }
      }

      // ─────────────────────────────────────────────────────────
      // STEP 2 — Process payments using real server IDs
      // ─────────────────────────────────────────────────────────
      for (final order in offlineOrders) {
        final serverOrderId = serverIdMap[order.localOrderId] ?? 0;

        if (serverOrderId == 0) {
          // Server didn't return an ID for this order — mark failed
          debugPrint("⚠️ No serverOrderId for ${order.localOrderId}, skipping payment");
          await updateOrder(order.copyWith(syncStatus: SyncStatus.failed));
          continue;
        }

        try {
          final paymentRef = "txn-${DateTime.now().millisecondsSinceEpoch}";

          final response = await paymentDatasource.processPayment(
            orderId: serverOrderId.toString(),  // ✅ real server ID
            amount: order.total,
            localOrderId: order.localOrderId,
            paymentMode: order.paymentMode.isNotEmpty ? order.paymentMode : "OFFLINE",
            paymentRef: paymentRef,
            serverOrderId: serverOrderId,       // ✅ real server ID
          );

          final paidOrder = order.copyWith(
            serverOrderId: serverOrderId,
            paymentMode: order.paymentMode.isNotEmpty ? order.paymentMode : "OFFLINE",
            paymentRef: ParsingHelper.parseStringMethod(response["paymentRef"]),
            paymentStatus: ParsingHelper.parseStringMethod(response["status"]),
            syncStatus: SyncStatus.paid,
          );

          await updateOrder(paidOrder);
        } catch (e) {
          debugPrint("❌ processPayment failed for ${order.localOrderId}: $e");
          await updateOrder(order.copyWith(syncStatus: SyncStatus.failed));
        }
      }

      // ─────────────────────────────────────────────────────────
      // STEP 3 — Reload & sync payments that reached `paid`
      // ─────────────────────────────────────────────────────────
      await loadOrders();

      final paidOrders = orders
          .where((e) => e.syncStatus == SyncStatus.paid)
          .toList();

      if (paidOrders.isEmpty) return;

      try {
        await syncDatasource.syncPayments(paidOrders); // ✅ now sends full payment data
      } catch (e) {
        debugPrint("❌ syncPayments failed: $e");
        // Don't mark as failed — payments ARE processed, just not synced
        // They'll be retried next time
        return;
      }

      // ─────────────────────────────────────────────────────────
      // STEP 4 — Mark synced
      // ─────────────────────────────────────────────────────────
      for (final order in paidOrders) {
        await updateOrder(order.copyWith(syncStatus: SyncStatus.synced));
      }

      debugPrint("✅ syncOfflineOrders complete — ${paidOrders.length} order(s) synced");
    } catch (e) {
      debugPrint("❌ syncOfflineOrders unexpected error: $e");
    } finally {
      isSyncing = false;
      notifyListeners();
    }
  }

  /// RETRY FAILED ORDERS

  Future<void> retryFailedOrders() async {
    await loadOrders();

    final failedOrders = orders
        .where((e) => e.syncStatus == SyncStatus.failed)
        .toList();

    for (final order in failedOrders) {
      final retryCount = (order.retryCount ?? 0) + 1;

      if (retryCount > 3) {
        debugPrint("⛔ Order ${order.localOrderId} exceeded max retries, skipping");
        continue;
      }

      await updateOrder(
        order.copyWith(
          syncStatus: SyncStatus.pending,
          retryCount: retryCount,  // requires adding retryCount field to OrderModel
        ),
      );
    }

    await syncOfflineOrders();
  }
}
