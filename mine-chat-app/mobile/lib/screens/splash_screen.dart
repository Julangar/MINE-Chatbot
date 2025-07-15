import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF131118), // Fondo personalizado
      body: SafeArea(
        child: Column(
          children: [
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
                    fontSize: 24,
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
                  child: const Text(
                    'Get Started',
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
