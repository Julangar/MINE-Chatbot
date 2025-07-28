import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mine_app/l10n/app_localizations.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _error;
  bool _loading = false;

  void _login() async {
    setState(() {
      _error = null;
      _loading = true;
    });
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final email = _emailController.text.trim();
    final pass = _passwordController.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      setState(() {
        _error = "All fields are required";
        _loading = false;
      });
      return;
    }
    final err = await auth.loginWithEmail(email, pass);
    setState(() => _loading = false);

    if (err == null) {
      Navigator.pushReplacementNamed(context, '/avatar_personality');
    } else {
      setState(() => _error = err);
    }
  }

  void _googleSignIn() async {
    setState(() {
      _error = null;
      _loading = true;
    });
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final err = await auth.signInWithGoogle();
    setState(() => _loading = false);
    if (err == null) {
      Navigator.pushReplacementNamed(context, '/avatar_personality');
    } else {
      setState(() => _error = err);
    }
  }

  void _appleSignIn() async {
    setState(() {
      _error = null;
      _loading = true;
    });
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final err = await auth.signInWithApple();
    setState(() => _loading = false);
    if (err == null) {
      Navigator.pushReplacementNamed(context, '/avatar_personality');
    } else {
      setState(() => _error = err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF131118),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Text(
                  AppLocalizations.of(context)!.signIn,
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF2d2938),
                  hintText: AppLocalizations.of(context)!.email,
                  hintStyle: const TextStyle(color: Color(0xFFa59db8)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF2d2938),
                  hintText: AppLocalizations.of(context)!.password,
                  hintStyle: const TextStyle(color: Color(0xFFa59db8)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              if (_error != null)
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/forgot_password');// Acción al presionar el botón de "Olvidé mi contraseña"
                  },
                  child: Text(
                    AppLocalizations.of(context)!.forgotPassword,
                    style: const TextStyle(
                      color: Color(0xFFa59db8),
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5619e5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                        ),
                        onPressed: _login,
                        child: Text(
                          AppLocalizations.of(context)!.signIn,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.white24)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text("or", style: TextStyle(color: Colors.white70)),
                  ),
                  Expanded(child: Divider(color: Colors.white24)),
                ],
              ),
              const SizedBox(height: 16),
              // Google Sign-In
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                  ),
                  icon: Image.asset('assets/google_logo.png', height: 24),
                  label: const Text("Sign in with Google", style: TextStyle(color: Colors.black87)),
                  onPressed: _googleSignIn,
                ),
              ),
              const SizedBox(height: 16),
              // Apple Sign-In
              if (Platform.isIOS || Platform.isMacOS)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                    ),
                    icon: const Icon(Icons.apple, color: Colors.white, size: 28),
                    label: const Text("Sign in with Apple", style: TextStyle(color: Colors.white)),
                    onPressed: _appleSignIn,
                  ),
                ),
              const SizedBox(height: 24),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/register'),
                  child: Text(
                    AppLocalizations.of(context)!.noAccountRegister,
                    style: const TextStyle(color: Color(0xFFa59db8), fontSize: 14, decoration: TextDecoration.underline),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
