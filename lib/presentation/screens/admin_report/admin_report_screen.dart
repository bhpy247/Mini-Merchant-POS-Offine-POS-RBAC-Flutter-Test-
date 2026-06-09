import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_enums.dart';
import '../../providers/order_provider.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();

    double revenue = 0;

    int pending = 0;

    for (final order in provider.orders) {
      revenue += order.total;

      if (order.syncStatus == SyncStatus.pending) {
        pending++;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Reports")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            Card(
              child: ListTile(title: const Text("Total Revenue"), subtitle: Text("₹$revenue")),
            ),

            Card(
              child: ListTile(title: const Text("Pending Sync"), subtitle: Text("$pending Orders")),
            ),
          ],
        ),
      ),
    );
  }
}
