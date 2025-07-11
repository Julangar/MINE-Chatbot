import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/create_avatar_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(const MineApp());
}

class MineApp extends StatelessWidget {
  const MineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MINE',
      theme: ThemeData(
        fontFamily: 'NotoSans', // o usa GoogleFonts si prefieres
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/avatar': (context) => const CreateAvatarScreen(),
        '/chat': (context) => const ChatScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
