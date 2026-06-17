import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<String> createOrder({
    required List<Map<String, dynamic>> items,
    required int totalAmount,
  }) async {
    final doc = await _firestore.collection('orders').add({
      'userId': _auth.currentUser!.uid,
      'items': items,
      'totalAmount': totalAmount,
      'status': 'paid',
      'createdAt': Timestamp.now(),
    });

    return doc.id;
  }
}
