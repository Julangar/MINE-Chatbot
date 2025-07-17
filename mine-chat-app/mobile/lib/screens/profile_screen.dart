import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mine_chatbot/l10n/app_localizations.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
  if (!auth.isLoggedIn) {
    Future.microtask(() => Navigator.pushReplacementNamed(context, '/login'));
    return const SizedBox(); // o un loader
  }
  // ... tu pantalla protegida aquí
    return Scaffold(
      backgroundColor: const Color(0xFF131118),
      appBar: AppBar(
        backgroundColor: const Color(0xFF131118),
        elevation: 0,
        title: const Text("My Profile", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Avatar y datos
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundImage: NetworkImage("https://lh3.googleusercontent.com/aida-public/AB6AXuCT1j4lZsZhMqkzqoWdQWs3J2dvdP1QddnCN0yay4rg23imqGMJlEXLf1KQbQcM8iHtN8lUr0n8jsS54op7ZYRuhFePTfAl4URv7PsyzYri6RDeEjkGgF5_YvxrsCmIgpvegWzpiGaX-pyJhZN8K4OH02pGVBadS5uF9yqh6lEDDgF3vo_jCRIQBPjdVm5aG9XmtrkvqSCDfkvUSSpTlEsq9wbxUjEiafYgse2FT3B-O6JkmOLHJMTPYbPozehfcssWB4L9FXSHvMAk"),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Sophia Carter",
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      "sophia.carter@email.com",
                      style: TextStyle(color: Color(0xFFa59db8), fontSize: 16),
                    ),
                  ],
                ),
              ),
              // Campos editables
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Name",
                    labelStyle: const TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: const Color(0xFF2d2938),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Email",
                    labelStyle: const TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: const Color(0xFF2d2938),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
              ),
              // Botón Guardar cambios
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                child: SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5619e5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                    ),
                    onPressed: () {},
                    child: const Text(
                      "Save Changes",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
              // Opciones
              const Padding(
                padding: EdgeInsets.only(left: 16, top: 12, bottom: 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Options",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ),
              ListTile(
                tileColor: const Color(0xFF131118),
                title: const Text("Change Password", style: TextStyle(color: Colors.white)),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
                onTap: () {},
              ),
              ListTile(
                tileColor: const Color(0xFF131118),
                title: const Text("Log Out", style: TextStyle(color: Colors.white)),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
                onTap: () {
                  Provider.of<AuthProvider>(context, listen: false).logout();
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
              // Ayuda / contacto
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  "Help or Contact Us",
                  style: TextStyle(color: Color(0xFFa59db8), fontSize: 14, decoration: TextDecoration.underline),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
