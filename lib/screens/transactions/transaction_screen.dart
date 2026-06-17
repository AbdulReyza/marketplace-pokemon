import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TransactionScreen extends StatelessWidget {
  const TransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        backgroundColor: const Color(0xFFE3350D),
        title: const Text(
          "Transaction History",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('wallet_transactions')
            .where('uid', isEqualTo: uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final transactions = snapshot.data!.docs;

          if (transactions.isEmpty) {
            return const Center(
              child: Text(
                "No Transactions Yet",
                style: TextStyle(color: Colors.grey, fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final data = transactions[index].data() as Map<String, dynamic>;

              final isTopup = data['type'] == 'topup';

              final timestamp = data['createdAt'] as Timestamp?;

              final date = timestamp != null
                  ? timestamp.toDate().toString()
                  : '-';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isTopup
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                    child: Icon(
                      isTopup ? Icons.add : Icons.shopping_cart,
                      color: isTopup ? Colors.green : Colors.red,
                    ),
                  ),

                  title: Text(
                    isTopup ? "Top Up Wallet" : "Pokemon Purchase",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  subtitle: Text(date),

                  trailing: Text(
                    "${isTopup ? '+' : '-'} Rp ${data['amount']}",
                    style: TextStyle(
                      color: isTopup ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
