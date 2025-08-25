import 'package:flutter/material.dart';

class ChatBackgroundProvider with ChangeNotifier {
  // id o key del fondo elegido
  String _backgroundId = 'assets/backgrounds/bg1.png';
  String get backgroundId => _backgroundId;
  // opcional: color/gradiente si no usas imagen
  Color _bubbleColor = const Color(0xFF201A35);
  Color get bubbleColor => _bubbleColor;

  void setBackground(String id) {
    if (_backgroundId == id) return;
    _backgroundId = id;
    notifyListeners();
  }

  void setBubbleColor(Color color) {
    if (_bubbleColor == color) return;
    _bubbleColor = color;
    notifyListeners();
  }
}
