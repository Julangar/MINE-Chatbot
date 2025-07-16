import 'package:flutter/material.dart';

void showFeedbackSnackbar(BuildContext context, String message, {bool success = true}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: success ? Colors.green : Colors.red,
      duration: const Duration(seconds: 2),
    ),
  );
}
