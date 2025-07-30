import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mine_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'widgets/auth_guard.dart';
import 'providers/locale_provider.dart';
import 'providers/auth_provider.dart';
import 'controllers/avatar_controller.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/create_avatar_screen.dart';
import 'screens/avatar_personality_screen_v2.dart';
import 'screens/chat_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/avatar_summary_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AvatarController()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: const MineApp(),
    ),
  );
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
      },
    );
  }
}
