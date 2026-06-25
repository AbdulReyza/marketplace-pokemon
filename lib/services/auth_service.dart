import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import 'package:base32/base32.dart';
import '../screens/auth/email_service.dart';
import 'dart:typed_data';

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

  String generateSecretKey() {
    final random = Random.secure();

    return base32
        .encode(
          Uint8List.fromList(List.generate(20, (_) => random.nextInt(256))),
        )
        .replaceAll('=', '');
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
    final secretKey = generateSecretKey();

    await _firestore.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'isVerified': false,
      'totpSecret': secretKey,
      'totpEnabled': true,
      'createdAt': Timestamp.now(),
    });

    await EmailService().sendAuthenticatorKey(
      email: email,
      secretKey: secretKey,
    );

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
    final userDoc = await _firestore.collection('users').doc(user.uid).get();

    final userData = userDoc.data();

    if (userData != null &&
        (userData['totpSecret'] == null ||
            userData['totpSecret'].toString().isEmpty)) {
      final secretKey = generateSecretKey();

      await _firestore.collection('users').doc(user.uid).update({
        'totpSecret': secretKey,
        'totpEnabled': true,
      });

      await EmailService().sendAuthenticatorKey(
        email: user.email!,
        secretKey: secretKey,
      );
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
