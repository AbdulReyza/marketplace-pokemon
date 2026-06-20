import 'package:flutter/material.dart';
import '../auth/otp_totp_authenticator.dart';
import '../../services/wallet_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CheckoutScreen extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final int totalAmount;

  const CheckoutScreen({
    super.key,
    required this.items,
    required this.totalAmount,
  });
  Future<String?> showPinDialog(BuildContext context) async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("Pokemon Wallet PIN"),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 6,
            decoration: const InputDecoration(hintText: "Enter 6 digit PIN"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, controller.text);
              },
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        backgroundColor: const Color(0xFFE3350D),
        title: const Text("Checkout", style: TextStyle(color: Colors.white)),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Order Summary",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];

                  return Card(
                    child: ListTile(
                      title: Text(item['name']),
                      subtitle: Text("Qty: ${item['quantity']}"),
                      trailing: Text("Rp ${item['price']}"),
                    ),
                  );
                },
              ),
            ),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  Text(
                    "Rp $totalAmount",
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFFE3350D),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE3350D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AuthVerificationScreen(
                        onVerified: () async {
                          Navigator.pop(context);

                          final pin = await showPinDialog(context);
                          if (pin == null) return;

                          final uid = FirebaseAuth.instance.currentUser!.uid;

                          final walletDoc = await FirebaseFirestore.instance
                              .collection('wallets')
                              .doc(uid)
                              .get();

                          final walletData = walletDoc.data();

                          if (walletData == null) return;

                          if (walletData['pin'] != pin) return;

                          final success = await WalletService().pay(
                            totalAmount,
                          );

                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Pembayaran berhasil"),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  );
                },
                child: const Text(
                  "Pay With Pokemon Wallet",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
