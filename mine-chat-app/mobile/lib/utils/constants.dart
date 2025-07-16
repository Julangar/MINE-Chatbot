import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF131118);
  static const primary = Color(0xFF5619e5);
  static const secondary = Color(0xFFa59db8);
  static const success = Colors.green;
  static const error = Colors.red;
}

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const createAvatar = '/create_avatar';
  static const chat = '/chat';
  static const profile = '/profile';
}

class FirestoreCollections {
  static const users = 'users';
  static const avatars = 'avatars';
  // ...otros nombres de colecciones
}
