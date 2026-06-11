import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:minipostest/data/datasource/remote/payment_remote_datasource.dart';
import 'package:minipostest/data/datasource/remote/sync_remote_datasource.dart';
import 'package:minipostest/presentation/providers/connectivity_provider.dart';
import 'package:minipostest/presentation/providers/report_provider.dart';
import 'package:provider/provider.dart';

import 'core/services/connectivity_service.dart';
import 'core/services/hive_service.dart';

import 'core/utils/provider_refrence.dart';
import 'data/datasource/remote/auth_remote_datasource.dart';
import 'data/datasource/remote/cart_remote_datasource.dart';
import 'data/datasource/remote/order_remote_datasource.dart';
import 'data/datasource/remote/product_remote_datasource.dart';

import 'data/datasource/remote/report_remote_datasource.dart';
import 'data/repsitory/auth_repo_impl.dart';
import 'data/repsitory/product_repo_impl.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/cart_provider.dart';
import 'presentation/providers/order_provider.dart';
import 'presentation/providers/product_provider.dart';

import 'presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  await HiveService.init();

  final orderProvider = OrderProvider(
    OrderRemoteDatasource(),
    PaymentRemoteDatasource(),
    SyncRemoteDatasource(),
  );

  orderProviderReference = orderProvider;

  ConnectivityService.connectionStream.listen((isConnected) {
    if (isConnected) {
      orderProvider.syncOfflineOrders();
    }
  });

  runApp(MyApp(orderProvider: orderProvider));
}

class MyApp extends StatelessWidget {
  final OrderProvider orderProvider;

  const MyApp({super.key, required this.orderProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(AuthRepositoryImpl(AuthRemoteDatasource()))),

        ChangeNotifierProvider(
          create: (_) => ProductProvider(ProductRepositoryImpl(ProductRemoteDatasource())),
        ),

        ChangeNotifierProvider(create: (_) => CartProvider(CartRemoteDatasource())),

        ChangeNotifierProvider(create: (_) => orderProvider),
        ChangeNotifierProvider(create: (_) => ReportsProvider(ReportsRemoteDatasource())),
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
      ],

      child: MaterialApp(
        debugShowCheckedModeBanner: false,

        title: "Mini POS",

        theme: ThemeData(
          primarySwatch: Colors.blue,

          scaffoldBackgroundColor: Colors.white,

          appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
        ),

        home: const SplashScreen(),
      ),
    );
  }
}
