import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:mine_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _error;
  bool _loading = false;

  void _register() async {
    setState(() {
      _error = null;
      _loading = true;
    });
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final email = _emailController.text.trim();
    final pass = _passwordController.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      setState(() {
        _error = AppLocalizations.of(context)!.completeAll;
        _loading = false;
      });
      return;
    }
    if (pass.length < 8) {
      setState(() {
        _error = AppLocalizations.of(context)!.badPassword;
        _loading = false;
      });
      return;
    }
    final err = await auth.registerWithEmail(email, pass);
    setState(() => _loading = false);

    if (err == null) {
      Navigator.pushReplacementNamed(context, '/avatar');
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
      Navigator.pushReplacementNamed(context, '/avatar');
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
      Navigator.pushReplacementNamed(context, '/avatar');
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
                  AppLocalizations.of(context)!.register,
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
              const SizedBox(height: 16),
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5619e5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                          minimumSize: const Size.fromHeight(48),
                        ),
                        onPressed: _register,
                        child: Text(
                          AppLocalizations.of(context)!.register,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
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
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                    minimumSize: const Size.fromHeight(48),
                  ),
                  icon: Image.asset('assets/google_logo.png', height: 24),
                  label: const Text("Register with Google", style: TextStyle(color: Colors.black87)),
                  onPressed: _googleSignIn,
                ),
              ),
              const SizedBox(height: 16),
              // Apple Sign-In
              if (Platform.isIOS || Platform.isMacOS)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                      minimumSize: const Size.fromHeight(48),
                    ),
                    icon: Icon(Icons.apple, color: Colors.white, size: 28),
                    label: const Text("Register with Apple", style: TextStyle(color: Colors.white)),
                    onPressed: _appleSignIn,
                  ),
                ),
              const SizedBox(height: 24),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                  child: Text(
                    AppLocalizations.of(context)!.haveUserAccount,
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
