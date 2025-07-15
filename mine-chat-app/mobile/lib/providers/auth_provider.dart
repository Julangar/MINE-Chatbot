import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthProvider extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;

  User? get user => _auth.currentUser;
  bool get isLoggedIn => user != null;

  // Registro con email y contraseña
  Future<String?> registerWithEmail(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Login con email y contraseña
  Future<String?> loginWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Google Sign-In
  Future<String?> signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return "Google sign in canceled";
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // Apple Sign-In
  Future<String?> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
      await _auth.signInWithCredential(oauthCredential);
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // Cerrar sesión
  Future<void> logout() async {
    await _auth.signOut();
    notifyListeners();
  }
}
