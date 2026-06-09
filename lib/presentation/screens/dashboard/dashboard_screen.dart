import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/storage_service.dart';
import '../../../core/utils/permission_handler.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../admin_report/admin_report_screen.dart';
import '../cart/cart_screen.dart';
import '../login/login_screen.dart';
import '../order/order_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String role = "";

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      context.read<ProductProvider>().getProducts();
      role = await StorageService.getRole() ?? "ADMIN";
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    final productProvider = context.watch<ProductProvider>();
    final cartProvider = context.watch<CartProvider>();
    //
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard - $role"),

        actions: [
          IconButton(
            onPressed: () async {
              await StorageService.clear();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),

      body: productProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await productProvider.getProducts();
              },

              child: ListView.builder(
                itemCount: productProvider.products.length,

                itemBuilder: (context, index) {
                  final product = productProvider.products[index];
                  final qty = cartProvider.getProductQuantity(product.id);

                  return Card(
                    margin: const EdgeInsets.all(10),

                    child: ListTile(
                      title: Text(product.name),

                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [Text("Price: ₹${product.price}"), Text("Stock: ${product.stock}")],
                      ),

                      trailing: Consumer<CartProvider>(
                        builder: (context, cartProvider, child) {
                          final qty = cartProvider.getProductQuantity(product.id);

                          return qty == 0
                              ? ElevatedButton(
                                  onPressed: () {
                                    cartProvider.addToCart(product);
                                  },

                                  child: const Text("Add"),
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(),

                                    borderRadius: BorderRadius.circular(10),
                                  ),

                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,

                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          cartProvider.decrementQty(product);
                                        },

                                        icon: const Icon(Icons.remove),
                                      ),

                                      Text("$qty"),

                                      IconButton(
                                        onPressed: () {
                                          cartProvider.addToCart(product);
                                        },

                                        icon: const Icon(Icons.add),
                                      ),
                                    ],
                                  ),
                                );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
