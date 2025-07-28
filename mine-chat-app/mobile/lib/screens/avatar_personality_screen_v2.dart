
import 'package:flutter/material.dart';
import '../controllers/avatar_controller.dart';
import '../widgets/avatar_personality_form.dart';
import 'create_avatar_screen.dart';

class AvatarPersonalityScreen extends StatefulWidget {
  final AvatarController controller;

  const AvatarPersonalityScreen({super.key, required this.controller});

  @override
  State<AvatarPersonalityScreen> createState() => _AvatarPersonalityScreenState();
}

class _AvatarPersonalityScreenState extends State<AvatarPersonalityScreen> {
  void _handleFormSubmit(Map<String, dynamic> formData) {
    widget.controller.name = formData['name'];
    widget.controller.setPersonality(
      interestsInput: List<String>.from(formData['interests']),
      style: formData['speakingStyle'],
      phrases: List<String>.from(formData['commonPhrases']),
      traitMap: Map<String, double>.from(formData['traits']),
    );
    widget.controller.userReference = formData['userReference'];
    widget.controller.relationshipOrRole = formData['relationshipOrRole'];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CreateAvatarScreen(), // Ya debe leer desde AvatarProvider
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Personaliza tu avatar')),
      body: AvatarPersonalityForm(onSubmit: _handleFormSubmit),
    );
  }
}
