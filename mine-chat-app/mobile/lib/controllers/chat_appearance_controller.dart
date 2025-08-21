// lib/controllers/chat_appearance_controller.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_background.dart';

class ChatAppearanceController extends ChangeNotifier {
  ChatBackground _background = const ChatBackground(type: ChatBackgroundType.dynamic, blur: 0);
  ChatBackground get background => _background;
  final String? userId;
  ChatAppearanceController({required this.userId});

  static const _prefsKey = 'chat_background_v1';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      _background = ChatBackground.fromMap(jsonDecode(raw));
      notifyListeners();
    }
    // nube (best-effort)
    if (userId != null) {
      final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('settings')
        .doc('chatAppearance')
        .get();
      if (snap.exists) {
        _background = ChatBackground.fromMap(snap.data()!);
        notifyListeners();
        // sincroniza local
        await _saveLocal(_background);
      }
    }
  }

  Future<void> setBackground(ChatBackground bg) async {
    _background = bg;
    notifyListeners();
    await _saveLocal(bg);
    await _saveRemote(bg);
  }

  Future<void> _saveLocal(ChatBackground bg) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(bg.toMap()));
  }

  Future<void> _saveRemote(ChatBackground bg) async {
    if (userId == null) return;
    await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('settings')
      .doc('chatAppearance')
      .set(bg.toMap(), SetOptions(merge: true));
  }
}
