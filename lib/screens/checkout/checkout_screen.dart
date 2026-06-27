import 'package:flutter/material.dart';
import 'dart:async'; // Tambah import dart:async
// import '../auth/otp_totp_authenticator.dart';
import '../../services/cart_services.dart';
// import '../../services/wallet_service.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import '../../services/order_service.dart';
import '../../services/deep_link_service.dart';
import '../../services/payment_callback_service.dart'; // Tambah import payment callback

class CheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final int totalAmount;

  const CheckoutScreen({
    super.key,
    required this.items,
    required this.totalAmount,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  StreamSubscription? _paymentSub; // Tambah properti StreamSubscription

  @override
  void initState() {
    super.initState();

    // Inisialisasi stream listener untuk callback pembayaran
    _paymentSub = PaymentCallbackService.instance.stream.listen((_) async {
      await OrderService().createOrder(
        items: widget.items, // Menggunakan widget.items
        totalAmount: widget.totalAmount, // Menggunakan widget.totalAmount
      );

      await CartService().clearCart();

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Pembayaran berhasil")));

      Navigator.popUntil(context, (route) => route.isFirst);
    });
  }

  @override
  void dispose() {
    _paymentSub?.cancel(); // Cancel subscription saat widget dihancurkan
    super.dispose();
  }

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
                itemCount: widget.items.length, // Menggunakan widget.items
                itemBuilder: (context, index) {
                  final item = widget.items[index]; // Menggunakan widget.items

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
                    "Rp ${widget.totalAmount}", // Menggunakan widget.totalAmount
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
                onPressed: () async {
                  final opened = await DeepLinkService.instance.openWallet(
                    amount: widget.totalAmount,
                  );

                  if (!mounted) return;

                  if (!opened) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Pokemon Wallet belum terinstall"),
                      ),
                    );
                  }
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
