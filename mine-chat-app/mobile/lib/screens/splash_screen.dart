import 'package:flutter/material.dart';
import 'package:mine_chatbot/l10n/app_localizations.dart';
import '../widgets/language_switcher.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Quita backgroundColor, usa un Container con gradient
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF5619e5),   // Violeta principal
                Color(0xFF453089),   // Azul-violeta oscuro
                Color(0xFF1A1838),   // Fondo muy oscuro
              ],
              stops: [0.1, 0.7, 1.0], // Puedes ajustar los stops para suavizar la transición
            ),
          ),
          child: Stack(
            children: [
              // Columna principal
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  // LOGO GRANDE
                  FractionallySizedBox(
                    widthFactor: 0.75,
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Image.asset(
                        'assets/LogoMineTransparente.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // SLOGAN
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      'Recreate me, forever',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Spacer(),
                  // BOTÓN
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
                          AppLocalizations.of(context)!.getStarted,
                          style: const TextStyle(
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
              // Selector de idioma en la parte superior derecha
              Positioned(
                top: 16,
                right: 16,
                child: LanguageSwitcher(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}