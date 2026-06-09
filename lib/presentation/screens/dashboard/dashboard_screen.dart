import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/storage_service.dart';
import '../../../core/utils/permission_handler.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../cart/cart_screen.dart';
import '../login/login_screen.dart';
import '../order/order_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<ProductProvider>().getProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    final productProvider = context.watch<ProductProvider>();
    final cartProvider = context.read<CartProvider>();

    final role = authProvider.user?.role ?? "";

    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard - $role"),

        actions: [
          IconButton(
            onPressed: () async {
              await StorageService.clear();

              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
            icon: const Icon(Icons.logout),
          ),
          if (PermissionHelper.canCreateOrder(role))
            IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
              },
              icon: const Icon(Icons.shopping_cart),
            ),
          if (PermissionHelper.canViewAllOrders(role))
            IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersScreen()));
              },
              icon: const Icon(Icons.list),
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

                  return Card(
                    margin: const EdgeInsets.all(10),

                    child: ListTile(
                      title: Text(product.name),

                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Price: ₹${product.price}"),

                          Text("Stock: ${product.stock}"),
                        ],
                      ),

                      trailing: ElevatedButton(
                        onPressed: () {
                          cartProvider.addToCart(product);

                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text("${product.name} added")));
                        },
                        child: const Text("Add"),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
