import 'dart:convert';
import 'package:http/http.dart' as http;

class EmailService {
  Future<void> sendAuthenticatorKey({
    required String email,
    required String secretKey,
  }) async {
    await http.post(
      Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'service_id': 'service_1rjubvz',
        'template_id': 'template_tdbtvry',
        'user_id': 'wC-lCh6sb90jUwDCT',
        'template_params': {
          'to_email': email,
          'secret_key': secretKey,
          'account_email': email,
        },
      }),
    );
  }
}
