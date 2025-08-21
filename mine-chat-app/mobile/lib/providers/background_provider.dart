import 'package:flutter/material.dart';

class ChatBackgroundProvider with ChangeNotifier {
  String _backgroundPath = 'assets/backgrounds/bg1.png';

  String get backgroundPath => _backgroundPath;

  void setBackground(String path) {
    _backgroundPath = path;
    notifyListeners();
  }
}
