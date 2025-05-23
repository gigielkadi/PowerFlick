import 'package:flutter/services.dart';
import 'package:uni_links/uni_links.dart';
import 'package:flutter/material.dart';

class DeepLinkService {
  static Future<void> handleInitialLink(BuildContext context) async {
    try {
      final initialLink = await getInitialLink();
      if (initialLink != null) {
        _handleLink(initialLink, context);
      }
    } on PlatformException {
      // Handle exception
    }
  }

  static void initUniLinks(BuildContext context) {
    linkStream.listen((String? link) {
      if (link != null) {
        _handleLink(link, context);
      }
    }, onError: (err) {
      print('Deep link error: $err');
    });
  }

  static void _handleLink(String link, BuildContext context) {
    if (link.contains('verified')) {
      // Navigate to login page after verification
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }
} 