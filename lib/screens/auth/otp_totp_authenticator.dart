import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:otp/otp.dart';

class AuthVerificationScreen extends StatefulWidget {
  const AuthVerificationScreen({super.key});

  @override
  State<AuthVerificationScreen> createState() => _AuthVerificationScreenState();
}

Future<String?> getSecret() async {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .get();

  return doc.data()?['totpSecret'];
}

class _AuthVerificationScreenState extends State<AuthVerificationScreen> {
  final pinController = TextEditingController();

  bool loading = false;

  Timer? timer;
  int remainingSeconds = 30;

  @override
  void initState() {
    super.initState();
    startTotpTimer();
  }

  void startTotpTimer() {
    updateRemainingSeconds();

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      updateRemainingSeconds();
    });
  }

  void updateRemainingSeconds() {
    final epochSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    setState(() {
      remainingSeconds = 30 - (epochSeconds % 30);

      if (remainingSeconds == 30) {
        remainingSeconds = 0;
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    pinController.dispose();
    super.dispose();
  }

  Future<void> verify() async {
    setState(() => loading = true);

    try {
      final secret = await getSecret();

      if (secret == null || secret.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Secret key tidak ditemukan")),
        );

        setState(() => loading = false);
        return;
      }

      final currentCode = OTP.generateTOTPCodeString(
        secret,
        DateTime.now().millisecondsSinceEpoch,
        interval: 30,
        algorithm: Algorithm.SHA1,
        isGoogle: true,
      );

      if (pinController.text.trim() == currentCode) {
        if (!mounted) return;
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Authenticator code salah")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = remainingSeconds / 30;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3350D), Color(0xFF3B82F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// AUTHENTICATOR CARD
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.shield,
                          color: Colors.greenAccent,
                          size: 50,
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          "Google Authenticator",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 16),

                        const Text(
                          "Open Google Authenticator",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 20),

                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.white24,
                        ),

                        const SizedBox(height: 10),

                        Text(
                          "Code refresh in ${remainingSeconds}s",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Authenticator Verification",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Masukkan kode 6 digit dari Google Authenticator",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.verified_user, color: Colors.green),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Two-Factor Authentication Enabled",
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: pinController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 6,
                    style: const TextStyle(
                      letterSpacing: 8,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      counterText: "",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      hintText: "123456",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE3350D), Color(0xFF3B82F6)],
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: loading ? null : verify,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: loading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "VERIFY",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
