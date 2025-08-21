// lib/data/chat_background_presets.dart
import 'package:flutter/material.dart';
import '../models/chat_background.dart';

final chatBackgroundPresets = <ChatBackground>[
  const ChatBackground(type: ChatBackgroundType.dynamic, blur: 0),
  ChatBackground(type: ChatBackgroundType.solid, color: const Color(0xFFF6F2FF)),
  ChatBackground(type: ChatBackgroundType.solid, color: const Color(0xFF0E1116)),
  ChatBackground(
    type: ChatBackgroundType.gradient,
    colors: const [Color(0xFF5B86E5), Color(0xFF36D1DC)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  ),
  ChatBackground(
    type: ChatBackgroundType.gradient,
    colors: const [Color(0xFF654EA3), Color(0xFFEAAFC8)],
  ),
  const ChatBackground(type: ChatBackgroundType.assetImage, image: 'assets/wallpapers/paper_light.jpg', blur: 0),
  const ChatBackground(type: ChatBackgroundType.assetImage, image: 'assets/wallpapers/fabric_dark.jpg', blur: 2),
];
ChatBackground getDefaultBackground() {
  return chatBackgroundPresets.firstWhere(
    (bg) => bg.type == ChatBackgroundType.dynamic,
    orElse: () => chatBackgroundPresets.first,
  );
}