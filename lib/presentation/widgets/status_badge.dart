import 'package:flutter/material.dart';

import '../../core/constants/app_enums.dart';

class StatusBadge extends StatelessWidget {
  final SyncStatus status;

  const StatusBadge({super.key, required this.status});

  Color getColor() {
    switch (status) {
      case SyncStatus.pending:
        return Colors.orange;

      case SyncStatus.orderCreated:
        return Colors.purple;

      case SyncStatus.paid:
        return Colors.blue;

      case SyncStatus.synced:
        return Colors.green;

      case SyncStatus.failed:
        return Colors.red;


    }
  }

  IconData getIcon() {
    switch (status) {
      case SyncStatus.pending:
        return Icons.pending;

      case SyncStatus.orderCreated:
        return Icons.receipt_long;

      case SyncStatus.paid:
        return Icons.payments;


      case SyncStatus.synced:
        return Icons.check_circle;

      case SyncStatus.failed:
        return Icons.error;


    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

      decoration: BoxDecoration(color: getColor(), borderRadius: BorderRadius.circular(20)),

      child: Row(
        mainAxisSize: MainAxisSize.min,

        children: [
          Icon(getIcon(), color: Colors.white, size: 18),

          const SizedBox(width: 6),

          Text(
            status.name.toUpperCase(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
