import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/report_provider.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<ReportsProvider>().loadReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReportsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Reports"),
        actions: [
          IconButton(
            onPressed: () {
              context.read<ReportsProvider>().loadReports();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Card(
                    child: ListTile(
                      title: const Text("Today's Orders"),

                      subtitle: Text("${provider.totalOrders}"),
                    ),
                  ),

                  Card(
                    child: ListTile(
                      title: const Text("Today's Revenue"),

                      subtitle: Text("₹${provider.totalRevenue}"),
                    ),
                  ),

                  Card(
                    child: ListTile(
                      title: const Text("Pending Sync"),

                      subtitle: Text("${provider.pendingSync}"),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
