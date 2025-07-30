
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mine_app/l10n/app_localizations.dart';
import '../services/avatar_service.dart';
import '../widgets/avatar_personality_form.dart';

enum AvatarType { myself, love, friend, relative }

class AvatarPersonalityScreen extends StatefulWidget {
  const AvatarPersonalityScreen({super.key});

  @override
  State<AvatarPersonalityScreen> createState() => _AvatarPersonalityScreenState();
}

class _AvatarPersonalityScreenState extends State<AvatarPersonalityScreen> {
  AvatarType? _selectedType;
  bool _isSaving = false;

  String _getAvatarTypeString(AvatarType type) {
    switch (type) {
      case AvatarType.myself:
        return 'myself_avatar';
      case AvatarType.love:
        return 'love_avatar';
      case AvatarType.friend:
        return 'friend_avatar';
      case AvatarType.relative:
        return 'relative_avatar';
    }
  }

  void _savePersonality(Map<String, dynamic> data) async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;

    if (userId == null || _selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario no autenticado o tipo de avatar no seleccionado')));
      return;
    }

    setState(() => _isSaving = true);

    await AvatarService.saveAvatarPersonality(userId, _getAvatarTypeString(_selectedType!), data);

    setState(() => _isSaving = false);

    Navigator.pushNamed(context, '/create');
  }

  Widget _typeSelector() {
    final t = AppLocalizations.of(context)!;
    final descriptions = {
      AvatarType.myself: t.myself_avatar,
      AvatarType.love: t.love_avatar,
      AvatarType.friend: t.friend_avatar,
      AvatarType.relative: t.relative_avatar,
    };

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            t.selectAvatarType,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              _typeButton(AvatarType.love, "Love of Mine", Icons.favorite, descriptions[AvatarType.love]!),
              _typeButton(AvatarType.friend, "Friend of Mine", Icons.people, descriptions[AvatarType.friend]!),
              _typeButton(AvatarType.relative, "Relative of Mine", Icons.family_restroom, descriptions[AvatarType.relative]!),
              _typeButton(AvatarType.myself, "Myself", Icons.person, descriptions[AvatarType.myself]!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _typeButton(AvatarType type, String title, IconData icon, String description) {
    final isSelected = _selectedType == type;

    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.grey[850],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white70),
        ),
        child: Column(
          children: [
            Icon(icon, size: 36, color: isSelected ? Colors.black : Colors.white),
            const SizedBox(height: 8),
            Text(title,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.black : Colors.white),
                textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(description,
                style: TextStyle(fontSize: 12, color: isSelected ? Colors.black87 : Colors.white70),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.avatar_form_title),
        backgroundColor: Colors.black,
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : _selectedType == null
              ? _typeSelector()
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () => setState(() => _selectedType = null),
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          label: Text(AppLocalizations.of(context)!.change_avatar_type, style: const TextStyle(color: Colors.white)),
                        ),
                      ),
                    ),
                    Expanded(
                      child: AvatarPersonalityForm(onSubmit: _savePersonality),
                    ),
                  ],
                ),
    );
  }
}
