// lib/services/fcm_service.dart (arriba del todo o en un file dedicado a handlers)
// lib/services/fcm_service.dart
import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../utils/notification_router.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';


/// ------------- BACKGROUND HANDLER (Top-level) -------------
/// Se ejecuta cuando llega un push y la app está terminada o en background.
/// Aquí NO navegues directo (no hay contexto). Solo registra logs/analytics si quieres.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Puedes loguear métricas mínimas o actualizar badges.
  // print('BG message: ${message.data}');
}



class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  final _messaging = FirebaseMessaging.instance;
  final _firestore = FirebaseFirestore.instance;

  // Opcional: para mostrar notificación local cuando app está en foreground.
  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();
  static const AndroidNotificationChannel _androidChannel = AndroidNotificationChannel(
    'mine_default_channel',
    'MINE - Notificaciones',
    description: 'Mensajes y recordatorios del avatar',
    importance: Importance.high,
  );

  Future<void> initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const init = InitializationSettings(android: androidInit, iOS: iosInit);
    await _local.initialize(init,
      onDidReceiveNotificationResponse: (resp) {
        // Cuando el usuario toca una notificación local en foreground:
        final payload = resp.payload;
        if (payload == null) return;
        try {
          final data = Map<String, dynamic>.from(
            // ignore: unnecessary_cast
            (payload.isNotEmpty ? (payload.startsWith('{') ? (payload) : '{}') : '{}') as dynamic
          );
        } catch (_) {}
      },
    );

    await _local
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);
  }

  Future<void> requestPermissionsIfNeeded() async {
    if (Platform.isIOS) {
      await _messaging.requestPermission(
        alert: true, badge: true, sound: true, provisional: false,
      );
    } else if (Platform.isAndroid) {
      // Android 13+: POST_NOTIFICATIONS
      await _messaging.requestPermission();
    }
  }

  /// Llama esto después de que el usuario haya iniciado sesión (tenemos uid)
  Future<void> initAndRegisterToken(BuildContext context) async {
    await requestPermissionsIfNeeded();
    await initLocalNotifications();

    // iOS requiere esto para mostrar notis en foreground (banner/sonido)
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true, badge: true, sound: true,
    );

    // Token inicial
    final fcmToken = await _messaging.getToken();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null && fcmToken != null) {
      await _saveToken(uid, fcmToken);
    }

    // Rotación de token
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await _saveToken(uid, newToken);
      }
    });

    // App terminada → abierta por notificación
    final initialMsg = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMsg != null) {
      NotificationRouter.handle(context, initialMsg);
    }

    // App en background → vuelve al frente por notificación
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      NotificationRouter.handle(context, message);
    });

    // App en foreground → decide UI (banner/snack/local notification)
    FirebaseMessaging.onMessage.listen((message) async {
      // Si viene con 'notification', puedes mostrar local para unificar estilo.
      final title = message.notification?.title ?? 'MINE';
      final body  = message.notification?.body  ?? 'Tienes un nuevo mensaje';

      // Si prefieres banner nativo en iOS, ya está habilitado con setForegroundNotificationPresentationOptions.
      // Para Android, muestro local:
      await _local.show(
        message.hashCode,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: _encodePayload(message.data),
      );
    });
  }

  Future<void> _saveToken(String uid, String token) async {
    final doc = _firestore
        .collection('users')
        .doc(uid)
        .collection('devices')
        .doc(token);

    await doc.set({
      'token': token,
      'platform': Platform.isIOS ? 'ios' : 'android',
      'updatedAt': FieldValue.serverTimestamp(),
      // Útil si luego quieres segmentar por país/versión/appBuild, etc.
    }, SetOptions(merge: true));
  }

  String? _encodePayload(Map<String, dynamic> data) {
    try {
      return data.isEmpty ? '{}' : data.toString();
    } catch (_) {
      return '{}';
    }
  }
}