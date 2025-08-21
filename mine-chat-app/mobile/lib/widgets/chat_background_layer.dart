// lib/widgets/chat_background_layer.dart
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/chat_background.dart';

class ChatBackgroundLayer extends StatelessWidget {
  final ChatBackground background;
  const ChatBackgroundLayer({super.key, required this.background});

  @override
  Widget build(BuildContext context) {
    Widget base;
    switch (background.type) {
      case ChatBackgroundType.solid:
        base = Container(color: background.color ?? Theme.of(context).colorScheme.surface);
        break;
      case ChatBackgroundType.gradient:
        final colors = background.colors ??
            [
              Theme.of(context).colorScheme.surfaceVariant,
              Theme.of(context).colorScheme.surface,
            ];
        base = Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: background.begin ?? Alignment.topLeft,
              end: background.end ?? Alignment.bottomRight,
            ),
          ),
        );
        break;
      case ChatBackgroundType.assetImage:
        base = DecoratedBox(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(background.image!),
              fit: BoxFit.cover,
            ),
          ),
        );
        break;
      case ChatBackgroundType.networkImage:
        base = CachedNetworkImage(
          imageUrl: background.image!,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => Container(color: Colors.black12),
        );
        break;
      case ChatBackgroundType.dynamic:
        // usa colores del tema (ideal si ya tienes theming claro/oscuro)
        base = Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primaryContainer.withOpacity(0.35),
                Theme.of(context).colorScheme.surface,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        );
        break;
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        base,
        if (background.blur > 0)
          BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: background.blur,
              sigmaY: background.blur,
            ),
            child: Container(color: Colors.black.withOpacity(0)), // deja pasar el blur
          ),
      ],
    );
  }
}
