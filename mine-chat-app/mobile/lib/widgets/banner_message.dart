import 'package:flutter/material.dart';

class BannerMessage extends StatelessWidget {
  final String title;
  final String message;
  final Color? backgroundColor;
  final IconData? icon;

  const BannerMessage({
    super.key,
    required this.title,
    required this.message,
    this.backgroundColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16, top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xFF5619e5).withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, color: const Color(0xFF5619e5), size: 32),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Color(0xFF5619e5),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: const TextStyle(fontSize: 15, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
