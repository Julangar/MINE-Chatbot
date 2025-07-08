 import 'package:flutter/material.dart';

void main() {
  runApp(MineApp());
}

class MineApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MINE Chatbot',
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble, size: 100),
            SizedBox(height: 20),
            Text('Bienvenido a MINE'),
          ],
        ),
      ),
    );
  }
}
