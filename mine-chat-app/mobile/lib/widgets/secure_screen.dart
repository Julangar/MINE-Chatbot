import 'package:flutter/material.dart';
import 'package:screen_protector/screen_protector.dart';

class SecureScreen extends StatefulWidget {
  final Widget child;
  const SecureScreen({super.key, required this.child});
  @override
  State<SecureScreen> createState() => _SecureScreenState();
}

class _SecureScreenState extends State<SecureScreen> {
  @override
  void initState() {
    super.initState();
    ScreenProtector.preventScreenshotOn();
    ScreenProtector.protectDataLeakageOn();
  }
  @override
  void dispose() {
    ScreenProtector.preventScreenshotOff();
    ScreenProtector.protectDataLeakageOff();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) => widget.child;
}
