import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF131118),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                // Imagen de fondo superior
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 0),
                  child: Container(
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      image: const DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage("https://lh3.googleusercontent.com/aida-public/AB6AXuAdZgKBSSw4Aa9gDa5LYWtOMNeln9mymJBID_2LmWeE-hSVHrmYji7hMjlJ2oh_nRxfyw4vRU-ItKM2RaixULQonE1WCOLZ_iDvg2iEOH3816KScWkRsk3uodzJ3IOfv38t7E0nAARDXqMDlG6SdGAtSsNxAwnAPG2xPmkIlX4TedQjmXG0_Ob-PDnkd7FhmFKL8qNhWM-SA2ep94cNbIz4-rlYbooQcYjkhAIA7jeYM4qupi0eUsxWPXGMLg0JaP1HQjHk3pHsYtyM"),
                      ),
                    ),
                  ),
                ),
                // Imagen de fondo inferior
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      image: const DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage("assets/mineLogo.png"),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "mine",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Recreate me, forever",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5619e5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                  ),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Text(
                    "Get Started",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
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
