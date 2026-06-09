import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/order_provider.dart';
import '../../widgets/status_badge.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<OrderProvider>().loadOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();

    if (provider.orders.isEmpty) {
      return const Center(child: Text("No Orders Found"));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Orders"),
        actions: [
          IconButton(
            onPressed: () {
              context.read<OrderProvider>().retryFailedOrders();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      body: ListView.builder(
        itemCount: provider.orders.length,

        itemBuilder: (context, index) {
          final order = provider.orders[index];

          return Card(
            margin: const EdgeInsets.all(10),

            child: Padding(
              padding: const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(order.localOrderId, style: const TextStyle(fontWeight: FontWeight.bold)),

                  const SizedBox(height: 10),

                  Text("Total: ₹${order.total}"),

                  const SizedBox(height: 10),

                  StatusBadge(status: order.syncStatus),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
