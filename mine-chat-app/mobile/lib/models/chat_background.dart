// lib/models/chat_background.dart
import 'package:flutter/material.dart';

enum ChatBackgroundType {
  solid,        // color plano
  gradient,     // gradiente
  assetImage,   // imagen del bundle
  networkImage, // imagen desde Storage/URL
  dynamic,      // usa colorScheme primario/secundario
}

class ChatBackground {
  final ChatBackgroundType type;
  final Color? color;                   // solid/dynamic override
  final List<Color>? colors;            // gradient
  final Alignment? begin;               // gradient
  final Alignment? end;                 // gradient
  final String? image;                  // asset or url
  final double blur;                    // efecto blur sobre todo el fondo

  const ChatBackground({
    required this.type,
    this.color,
    this.colors,
    this.begin,
    this.end,
    this.image,
    this.blur = 0,
  });

  Map<String, dynamic> toMap() => {
    'type': type.name,
    'color': color?.value,
    'colors': colors?.map((c) => c.value).toList(),
    'begin': {'x': begin?.x, 'y': begin?.y},
    'end': {'x': end?.x, 'y': end?.y},
    'image': image,
    'blur': blur,
  };

  factory ChatBackground.fromMap(Map<String, dynamic> m) {
    final t = ChatBackgroundType.values.firstWhere(
      (e) => e.name == (m['type'] as String? ?? ChatBackgroundType.dynamic.name),
      orElse: () => ChatBackgroundType.dynamic,
    );
    List<Color>? parseColors() {
      final list = m['colors'] as List?; 
      return list?.map((v) => Color(v as int)).toList();
    }
    Alignment? parseAl(Map? a) => (a == null) ? null : Alignment((a['x']??0).toDouble(), (a['y']??0).toDouble());
    return ChatBackground(
      type: t,
      color: m['color'] != null ? Color(m['color']) : null,
      colors: parseColors(),
      begin: parseAl(m['begin']),
      end: parseAl(m['end']),
      image: m['image'] as String?,
      blur: (m['blur'] ?? 0).toDouble(),
    );
  }
}
