// lib/utils/notification_router.dart
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationRouter {
  /// Llama esto en:
  /// - getInitialMessage() (cold)
  /// - onMessageOpenedApp (warm)
  static void handle(BuildContext context, RemoteMessage message) {
    final data = message.data;
    final route = data['route'] as String? ?? '/chat';
    final paramsString = data['params'] as String?; // JSON opcional
    Map<String, dynamic> params = {};
    if (paramsString != null && paramsString.isNotEmpty) {
      try {
        params = json.decode(paramsString) as Map<String, dynamic>;
      } catch (_) {}
    }

    // Reglas sencillas; ajusta según tu navegación:
    switch (route) {
      case '/profile':
        Navigator.of(context).pushNamed('/profile', arguments: params);
        break;
      case '/avatar':
        Navigator.of(context).pushNamed('/avatar', arguments: params);
        break;
      case '/chat':
      default:
        Navigator.of(context).pushNamed('/chat', arguments: params);
        break;
    }
  }
}
