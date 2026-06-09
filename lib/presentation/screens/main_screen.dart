import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/services/storage_service.dart';
import '../../core/utils/permission_handler.dart';
import '../providers/auth_provider.dart';
import '../widgets/internet_banner.dart';
import 'admin_report/admin_report_screen.dart';
import 'cart/cart_screen.dart';
import 'dashboard/dashboard_screen.dart';
import 'order/order_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final role = context.read<AuthProvider>().user?.role ?? "ADMIN";
    final screens = [
      const DashboardScreen(),

      if (PermissionHelper.canCreateOrder(role)) const CartScreen(),

      if (PermissionHelper.canViewOwnOrders(role)) const OrdersScreen(),

      if (PermissionHelper.canViewReports(role)) const ReportsScreen(),
    ];

    final items = [
      const BottomNavigationBarItem(icon: Icon(Icons.store), label: "Products"),

      if (PermissionHelper.canCreateOrder(role))
        const BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Cart"),

      if (PermissionHelper.canViewOwnOrders(role))
        const BottomNavigationBarItem(icon: Icon(Icons.list), label: "Orders"),

      if (PermissionHelper.canViewReports(role))
        const BottomNavigationBarItem(icon: Icon(Icons.analytics), label: "Reports"),
    ];

    return Scaffold(
      body: Column(
        children: [
          const InternetBanner(),

          Expanded(
            child: IndexedStack(index: currentIndex, children: screens),
          ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,

        type: BottomNavigationBarType.fixed,

        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        items: items,
      ),
    );
  }
}
