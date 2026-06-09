import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CartProvider>();
    final orderProvider = context.read<OrderProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text("Cart")),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: provider.items.length,

              itemBuilder: (context, index) {
                final item = provider.items[index];

                return ListTile(
                  title: Text(item.product.name),

                  subtitle: Text("Qty: ${item.quantity}"),

                  trailing: Text("₹${item.product.price * item.quantity}"),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),

            child: Column(
              children: [
                Text(
                  "Total: ₹${provider.total}",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 16),

                ElevatedButton(
                  onPressed: () async {
                    await orderProvider.createOrder(items: provider.items, total: provider.total, );

                    provider.clearCart();

                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text("Order Created")));
                    }
                  },
                  child: const Text("Create Order"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
