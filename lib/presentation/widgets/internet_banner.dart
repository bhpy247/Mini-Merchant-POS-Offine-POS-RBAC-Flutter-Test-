import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/connectivity_provider.dart';

class InternetBanner extends StatelessWidget {
  const InternetBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ConnectivityProvider>();

    if (provider.isConnected) {
      return const SizedBox();
    }

    return Container(
      width: double.infinity,

      color: Colors.red,

      padding: const EdgeInsets.symmetric(vertical: 10),

      child: const Center(
        child: Text(
          "OFFLINE MODE",

          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
