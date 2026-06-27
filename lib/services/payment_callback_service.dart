import 'dart:async';

class PaymentCallbackService {
  PaymentCallbackService._();

  static final PaymentCallbackService instance = PaymentCallbackService._();

  final StreamController<bool> _controller = StreamController<bool>.broadcast();

  Stream<bool> get stream => _controller.stream;

  void paymentSuccess() {
    _controller.add(true);
  }

  void dispose() {
    _controller.close();
  }
}
