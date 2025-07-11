import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF131118),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Encabezado
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      "Sign In",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ),
                // Campo Email
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF2d2938),
                      hintText: "Email",
                      hintStyle: const TextStyle(color: Color(0xFFa59db8)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                // Campo Contraseña
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    obscureText: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF2d2938),
                      hintText: "Password",
                      hintStyle: const TextStyle(color: Color(0xFFa59db8)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 4),
                  child: Text(
                    "Forgot your password?",
                    style: const TextStyle(
                      color: Color(0xFFa59db8),
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                // Botón Entrar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5619e5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                      ),
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/avatar');
                      },
                      child: const Text(
                        "Enter",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                // Enlace Registrar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  child: Center(
                    child: Text(
                      "No account? Register",
                      style: const TextStyle(
                        color: Color(0xFFa59db8),
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Imagen decorativa (puedes omitir o personalizar)
            Container(
              height: 120,
              decoration: const BoxDecoration(
                // Puedes reemplazar por asset o eliminar si no usas SVGs
                color: Color(0xFF131118),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
