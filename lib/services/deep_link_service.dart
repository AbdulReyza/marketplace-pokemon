import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:url_launcher/url_launcher.dart';

class DeepLinkService {
  DeepLinkService._();

  static final DeepLinkService instance = DeepLinkService._();

  final AppLinks _appLinks = AppLinks();

  StreamSubscription<Uri>? _subscription;

  final StreamController<Uri> _controller = StreamController<Uri>.broadcast();

  Stream<Uri> get stream => _controller.stream;

  Future<void> init() async {
    final initial = await _appLinks.getInitialLink();

    if (initial != null) {
      _controller.add(initial);
    }

    _subscription = _appLinks.uriLinkStream.listen((uri) {
      _controller.add(uri);
    });
  }

  Future<bool> openWallet({required int amount}) async {
    final uri = Uri(
      scheme: "pokemonwallet",
      host: "pay",
      queryParameters: {"amount": amount.toString()},
    );

    print(uri);

    final result = await launchUrl(uri, mode: LaunchMode.externalApplication);

    print("launch result = $result");

    return result;
  }

  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}
