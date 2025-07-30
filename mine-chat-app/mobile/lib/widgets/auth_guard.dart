import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart'; // Ajusta el path según tu estructura

class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isLoggedIn) {
      // Usuario autenticado, muestra la pantalla protegida
      return child;
    } else {
      // Usuario NO autenticado, redirige al login
      Future.microtask(() {
        Navigator.of(context).pushReplacementNamed('/login');
      });
      // Mientras navega, muestra pantalla vacía/cargando
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
  }
}
