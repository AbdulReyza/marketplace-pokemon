import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get cartCollection {
    return _firestore.collection('users').doc(uid).collection('cart');
  }

  Future<void> addToCart(String productId) async {
    final doc = await cartCollection.doc(productId).get();

    if (doc.exists) {
      final qty = (doc.data()?['quantity'] ?? 1) as int;

      await cartCollection.doc(productId).update({'quantity': qty + 1});
    } else {
      await cartCollection.doc(productId).set({
        'productId': productId,
        'quantity': 1,
        'addedAt': Timestamp.now(),
      });
    }
  }

  Future<void> increaseQuantity(String productId) async {
    final doc = await cartCollection.doc(productId).get();

    final qty = (doc.data()?['quantity'] ?? 1) as int;

    await cartCollection.doc(productId).update({'quantity': qty + 1});
  }

  Future<void> decreaseQuantity(String productId) async {
    final doc = await cartCollection.doc(productId).get();

    final qty = (doc.data()?['quantity'] ?? 1) as int;

    if (qty <= 1) {
      await cartCollection.doc(productId).delete();
    } else {
      await cartCollection.doc(productId).update({'quantity': qty - 1});
    }
  }

  Future<void> removeItem(String productId) async {
    await cartCollection.doc(productId).delete();
  }

  Future<void> clearCart() async {
    final docs = await cartCollection.get();

    for (var doc in docs.docs) {
      await doc.reference.delete();
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getCartItems() {
    return cartCollection.snapshots();
  }
}
