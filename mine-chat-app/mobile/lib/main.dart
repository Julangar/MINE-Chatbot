import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mine_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'widgets/auth_guard.dart';
import 'widgets/secure_screen.dart';
import 'providers/locale_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/avatar_provider.dart';
import 'controllers/avatar_controller.dart';
import 'controllers/chat_appearance_controller.dart';
import 'services/fcm_service.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/create_avatar_screen.dart';
import 'screens/avatar_personality_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/avatar_summary_screen.dart';
import 'screens/chat_background_picker_screen.dart';

/// ------------- BACKGROUND HANDLER (Top-level) -------------
/// Se ejecuta cuando llega un push y la app está terminada o en background.
/// Aquí NO navegues directo (no hay contexto). Solo registra logs/analytics si quieres.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Puedes loguear métricas mínimas o actualizar badges.
  // print('BG message: ${message.data}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
 
  // Importante: registra el handler ANTES de usar FirebaseMessaging.instance
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // iOS: solicitar permisos
  final messaging = FirebaseMessaging.instance;
  if (Platform.isIOS) {
    await messaging.requestPermission(
      alert: true, badge: true, sound: true, provisional: false,
    );
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, badge: true, sound: true,
    );
  }

  // Obtener/registrar token y escuchar refresh
  await _ensureFcmTokenRegistered();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AvatarController()),
        ChangeNotifierProvider(create: (_) => AvatarProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => ChatAppearanceController(userId: AuthProvider().user?.uid)),
      ],
      child: const MineApp(),
    ),
  );
}
/// Sube el token a Firestore en una subcolección por usuario (server-driven friendly).
Future<void> _ensureFcmTokenRegistered() async {
  final user = AuthProvider().user;
  if (user == null) return; // Llama de nuevo tras login.

  final token = await FirebaseMessaging.instance.getToken();
  if (token == null) return;

  final tokensRef = FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('fcmTokens')
      .doc(token);

  await tokensRef.set({
    'token': token,
    'platform': Platform.isIOS ? 'ios' : 'android',
    'updatedAt': FieldValue.serverTimestamp(),
    'active': true,
    // Útil si luego haces segmentación por avatar:
    // 'avatarType': 'loveOfMine' (si aplica en tu app)
  }, SetOptions(merge: true));

  // Mantener token actualizado (cambios por reinstalación/refresh)
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('fcmTokens')
        .doc(newToken);
    await ref.set({
      'token': newToken,
      'platform': Platform.isIOS ? 'ios' : 'android',
      'updatedAt': FieldValue.serverTimestamp(),
      'active': true,
    }, SetOptions(merge: true));
  });
}

class MineApp extends StatelessWidget {
  const MineApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MINE',
      locale: localeProvider.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        fontFamily: 'NotoSans', // o usa GoogleFonts si prefieres
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),
        '/avatar_personality': (context) => const AuthGuard(child: AvatarPersonalityScreen()),
        '/avatar': (context) => const AuthGuard(child: CreateAvatarScreen()),
        '/avatar_summary': (context) => const AuthGuard(child: AvatarSummaryScreen()),
        '/chat': (context) => const AuthGuard(child: ChatScreen()),
        '/profile': (context) => const AuthGuard(child: ProfileScreen()),
        //'/avatar_personality': (context) => const AuthGuard(child: SecureScreen(child: AvatarPersonalityScreen())),
        //'/avatar': (context) => const AuthGuard(child: SecureScreen(child: CreateAvatarScreen())),
        //'/avatar_summary': (context) => const AuthGuard(child: SecureScreen(child: AvatarSummaryScreen())),
        //'/chat': (context) => const AuthGuard(child: SecureScreen(child: ChatScreen())),
        //'/profile': (context) => const AuthGuard(child: SecureScreen(child: ProfileScreen())),
      },
    );
  }
}
