import 'package:flutter/material.dart';
import 'package:mine_chatbot/l10n/app_localizations.dart';
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
             // LOGO GRANDE
            Expanded(
              flex: 4,
              child: Center(
                child: Image.asset(
                  'assets/LogoMineTransparente.png', // Usa aquí el nombre correcto del archivo
                  width: MediaQuery.of(context).size.width * 0.6,
                  fit: BoxFit.contain,
                ),
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
