import 'package:flutter/material.dart';
import 'package:mine_chatbot/l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import '../widgets/language_switcher.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 96, 76, 146), // Fondo personalizado
      body: SafeArea(
        child: Column(
          children: [
            // Selector de idioma en la parte superior derecha
            Positioned(
              top: 16,
              right: 16,
              child: LanguageSwitcher(),
            ),
            // LOGO ARRIBA
            Padding(
              padding: const EdgeInsets.only(top: 48.0),
              child: Image.asset(
                'assets/mineLogo.png', // Cambia a tu path
                height: 120,
                fit: BoxFit.contain,
              ),
            ),
            // EXPANDED PARA CENTRAR EL SLOGAN
            const Expanded(
              child: Center(
                child: Text(
                  'Recreate me, forever',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 1,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            // BOTÓN ABAJO
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 36.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5619e5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: Text(
                    AppLocalizations.of(context)!.getStarted, // Usa el texto localizado
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
