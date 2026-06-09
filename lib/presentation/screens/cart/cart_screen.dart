import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/snackbar_helper.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/payment_bottom_sheet.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CartProvider>();
    final orderProvider = context.watch<OrderProvider>();
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

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,

                    children: [
                      IconButton(
                        onPressed: () {
                          provider.decrementQty(item.product);
                        },

                        icon: const Icon(Icons.remove),
                      ),

                      Text("${item.quantity}"),

                      IconButton(
                        onPressed: () {
                          provider.addToCart(item.product);
                        },

                        icon: const Icon(Icons.add),
                      ),

                      IconButton(
                        onPressed: () {
                          provider.removeEntireItem(item.product.id);
                        },

                        icon: const Icon(Icons.delete, color: Colors.red),
                      ),
                    ],
                  ),
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
                  onPressed: orderProvider.isLoading
                      ? null
                      : () async {
                          try {
                            final order = await context.read<OrderProvider>().createOrder(
                              items: provider.items,

                              total: provider.total,
                            );

                            if (context.mounted && order.serverOrderId != 0) {
                              showModalBottomSheet(
                                context: context,

                                isScrollControlled: true,

                                builder: (_) {
                                  return PaymentBottomSheet(order: order);
                                },
                              );
                            }
                          } catch (e) {
                            SnackbarHelper.showError(context: context, message: "Failed to create order");
                          }
                        },

                  child: orderProvider.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,

                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text("Checkout"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
