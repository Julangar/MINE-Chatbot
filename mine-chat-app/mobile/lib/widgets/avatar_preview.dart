import 'dart:io';
import 'package:flutter/material.dart';

class AvatarPreview extends StatelessWidget {
  final File? image;
  final VoidCallback? onRemove;

  const AvatarPreview({super.key, this.image, this.onRemove});

  @override
  Widget build(BuildContext context) {
    if (image == null) return const SizedBox.shrink();

    return Stack(
      children: [
        ClipOval(
          child: Image.file(image!, width: 96, height: 96, fit: BoxFit.cover),
        ),
        if (onRemove != null)
          Positioned(
            right: 0,
            top: 0,
            child: GestureDetector(
              onTap: onRemove,
              child: const CircleAvatar(radius: 14, backgroundColor: Colors.red, child: Icon(Icons.close, size: 16, color: Colors.white)),
            ),
          ),
      ],
    );
  }
}
