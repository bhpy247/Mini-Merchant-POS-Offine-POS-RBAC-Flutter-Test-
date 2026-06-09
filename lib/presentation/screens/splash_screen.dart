import 'package:flutter/material.dart';
import 'package:minipostest/presentation/providers/auth_provider.dart';
import 'package:minipostest/presentation/screens/main_screen.dart';
import 'package:provider/provider.dart';

import '../../core/services/storage_service.dart';
import 'dashboard/dashboard_screen.dart';
import 'login/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    checkLogin();
  }

  Future<void> checkLogin() async {
    await Future.delayed(const Duration(seconds: 2));

    final token = await StorageService.getToken();



    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      String role = await StorageService.getRole() ?? "ADMIN";
      context.read<AuthProvider>().user?.copyWith(role: role);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Icon(Icons.point_of_sale, size: 100, color: Colors.blue.shade700),

            const SizedBox(height: 20),

            const Text("Mini POS", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),

            const SizedBox(height: 30),

            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
