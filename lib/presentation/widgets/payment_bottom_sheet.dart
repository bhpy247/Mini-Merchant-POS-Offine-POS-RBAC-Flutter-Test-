import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/snackbar_helper.dart';
import '../../data/models/order_model.dart';
import '../providers/connectivity_provider.dart';
import '../providers/order_provider.dart';

class PaymentBottomSheet extends StatefulWidget {
  final OrderModel order;

  const PaymentBottomSheet({super.key, required this.order});

  @override
  State<PaymentBottomSheet> createState() => _PaymentBottomSheetState();
}

class _PaymentBottomSheetState extends State<PaymentBottomSheet> {
  String paymentMode = "CARD";

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final connectivityProvider = context.watch<ConnectivityProvider>();

    final isConnected = connectivityProvider.isConnected;

    final isOfflineOrder = widget.order.serverOrderId == 0;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,

        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),

      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            /// TITLE
            const Text("Confirm Payment", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),

            const SizedBox(height: 20),

            /// INTERNET STATUS
            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(12),

              decoration: BoxDecoration(
                color: isConnected ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),

                borderRadius: BorderRadius.circular(12),
              ),

              child: Row(
                children: [
                  Icon(
                    isConnected ? Icons.wifi : Icons.wifi_off,

                    color: isConnected ? Colors.green : Colors.red,
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      isConnected ? "Internet Connected" : "No Internet Connection",

                      style: TextStyle(
                        color: isConnected ? Colors.green : Colors.red,

                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// OFFLINE ORDER WARNING
            if (isOfflineOrder)
              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(14),

                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),

                  borderRadius: BorderRadius.circular(12),
                ),

                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange),

                    SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        "This order was created offline. Payment will be processed automatically after sync.",

                        style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),

            if (isOfflineOrder) const SizedBox(height: 20),

            /// AMOUNT
            Text("Total Amount", style: TextStyle(color: Colors.grey[700])),

            const SizedBox(height: 8),

            Text(
              "₹${widget.order.total.toStringAsFixed(2)}",

              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 25),

            /// PAYMENT MODE
            const Text("Payment Method"),

            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              value: paymentMode,

              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),

              items: const [
                DropdownMenuItem(value: "CARD", child: Text("CARD")),

                DropdownMenuItem(value: "UPI", child: Text("UPI")),

                DropdownMenuItem(value: "CASH", child: Text("CASH")),
              ],

              onChanged: isOfflineOrder
                  ? null
                  : (value) {
                      if (value == null) {
                        return;
                      }

                      setState(() {
                        paymentMode = value;
                      });
                    },
            ),

            const SizedBox(height: 30),

            /// CONFIRM BUTTON
            SizedBox(
              width: double.infinity,

              height: 52,

              child: ElevatedButton(
                onPressed:
                    /// DISABLE CASES
                    isLoading || !isConnected || isOfflineOrder
                    ? null
                    : () async {
                        setState(() {
                          isLoading = true;
                        });

                        try {
                          await context.read<OrderProvider>().processPayment(widget.order, paymentMode);

                          if (context.mounted) {
                            SnackbarHelper.showSuccess(context: context, message: "Payment Successful");

                            Navigator.pop(context);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            SnackbarHelper.showError(context: context, message: "Payment Failed");
                          }
                        } finally {
                          if (mounted) {
                            setState(() {
                              isLoading = false;
                            });
                          }
                        }
                      },

                child: isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,

                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        isOfflineOrder
                            ? "Waiting For Sync"
                            : !isConnected
                            ? "No Internet"
                            : "Confirm Payment",
                      ),
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
