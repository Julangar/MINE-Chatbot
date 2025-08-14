// push_init.dart
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final _flutterLocal = FlutterLocalNotificationsPlugin();

Future<void> setupPush() async {
  await Firebase.initializeApp();

  final messaging = FirebaseMessaging.instance;

  // iOS: permisos
  if (Platform.isIOS) {
    await messaging.requestPermission(alert: true, badge: true, sound: true);
  }

  // Android: inicializar canal local para foreground
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidSettings, iOS: DarwinInitializationSettings());
  await _flutterLocal.initialize(initSettings);

  // Crear canal
  const androidChannel = AndroidNotificationChannel(
    'avatar_channel',
    'Avatar Messages',
    description: 'Mensajes proactivos del avatar',
    importance: Importance.high,
  );
  await _flutterLocal
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(androidChannel);

  // Token para tu backend
  final token = await messaging.getToken();
  // Enviar token a tu backend (asócialo al userId)
  // await ApiClient.saveFcmToken(token);

  // Mensajes en foreground → mostrar con notificación local
  FirebaseMessaging.onMessage.listen((RemoteMessage m) async {
    final n = m.notification;
    final android = m.notification?.android;
    if (n != null) {
      await _flutterLocal.show(
        n.hashCode,
        n.title ?? 'MINE',
        n.body ?? '',
        const NotificationDetails(
          android: AndroidNotificationDetails('avatar_channel', 'Avatar Messages'),
          iOS: DarwinNotificationDetails(),
        ),
        payload: m.data['deep_link'],
      );
    }
  });

  // Tap en la notificación con app terminada
  FirebaseMessaging.instance.getInitialMessage().then((m) {
    final link = m?.data['deep_link'];
    if (link != null) {
      // navegar a chat_screen, por ejemplo
    }
  });

  // Tap con app en background
  FirebaseMessaging.onMessageOpenedApp.listen((m) {
    final link = m.data['deep_link'];
    if (link != null) {
      // navegar a chat_screen
    }
  });
}
