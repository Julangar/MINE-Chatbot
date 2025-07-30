
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/avatar_personality_form.dart';

class AvatarPersonalityScreen extends StatelessWidget {
  const AvatarPersonalityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? 'anonymous_user';

    return Scaffold(
      appBar: AppBar(title: const Text("Personaliza tu avatar")),
      body: AvatarPersonalityForm(
        userId: userId,
        onSaved: () {
          Navigator.pushNamed(context, '/create');
        },
      ),
    );
  }
}
