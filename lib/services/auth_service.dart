import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<Map<String, dynamic>?> getCurrentUserData() async {
    final user = _auth.currentUser;

    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();

    return doc.data();
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user!;
    final uid = user.uid;

    // kirim email verifikasi
    await user.sendEmailVerification();

    // simpan user
    await _firestore.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'isVerified': false,
      'createdAt': Timestamp.now(),
    });

    // buat wallet
    await _firestore.collection('wallets').doc(uid).set({
      'balance': 0,
      'pin': '123456',
      'createdAt': Timestamp.now(),
    });

    // paksa logout setelah registrasi
    await _auth.signOut();

    throw Exception(
      "Registrasi berhasil. Silakan verifikasi email terlebih dahulu lalu login kembali.",
    );
  }

  Future<void> login({required String email, required String password}) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user!;

    await user.reload();

    if (!user.emailVerified) {
      await _auth.signOut();

      throw Exception(
        "Email belum diverifikasi. Silakan cek inbox atau folder spam.",
      );
    }

    // update status verified di firestore
    await _firestore.collection('users').doc(user.uid).update({
      'isVerified': true,
    });
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
