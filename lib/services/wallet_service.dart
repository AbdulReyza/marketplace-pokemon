import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WalletService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser!.uid;

  Future<bool> pay(int amount) async {
    final walletDoc = _firestore.collection('wallets').doc(uid);

    final doc = await walletDoc.get();

    if (!doc.exists) {
      throw Exception('Wallet tidak ditemukan');
    }

    final currentBalance = (doc.data()?['balance'] ?? 0) as int;

    if (currentBalance < amount) {
      return false;
    }

    await walletDoc.update({'balance': currentBalance - amount});

    await _firestore.collection('wallet_transactions').add({
      'uid': uid,
      'type': 'payment',
      'amount': amount,
      'createdAt': Timestamp.now(),
    });

    return true;
  }
}
