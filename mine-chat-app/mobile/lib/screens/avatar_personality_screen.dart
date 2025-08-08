import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import 'package:mine_app/l10n/app_localizations.dart';
import '../models/avatar.dart';
import '../providers/avatar_provider.dart';
import '../services/avatar_service.dart';
import '../widgets/avatar_personality_form.dart';
import '../widgets/banner_message.dart';

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

  Future<Map<String, dynamic>?> _checkIfAvatarExists(AvatarType type) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final collectionName = _getAvatarTypeString(type);
    final doc = await FirebaseFirestore.instance
        .collection('avatars')
        .doc(user.uid)
        .collection(collectionName)
        .doc('personality')
        .get();

    return doc.exists ? doc.data() : null;
  }

  Future<void> _handleTypeSelection(AvatarType type) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _selectedType = type);

    final existingData = await _checkIfAvatarExists(type);
    if (existingData == null) {
      return;
    }

    if (mounted) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: Text(AppLocalizations.of(context)!.avatarAlreadyExist),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }

    final avatar = Avatar(
      userId: user.uid,
      avatarType: _getAvatarTypeString(type),
      name: existingData['name'] ?? '',
      country: existingData['country'] ?? '',
      phoneNumber: existingData['phoneNumber'] ?? '',
      userReference: existingData['userReference'] ?? '',
      relationshipOrRole: existingData['relationshipOrRole'] ?? '',
      interests: List<String>.from(existingData['interests'] ?? []),
      speakingStyle: existingData['speakingStyle'] ?? '',
      commonPhrases: List<String>.from(existingData['commonPhrases'] ?? []),
      traits: Map<String, double>.from(existingData['traits'] ?? {}),
      imageUrl: existingData['imageUrl'],
      audioUrl: existingData['audioUrl'],
      videoUrl: existingData['videoUrl'],
      talkId: existingData['talkId'],
      userLanguage: existingData['userLanguage'],
    );

    if (mounted) {
      context.read<AvatarProvider>().setAvatar(avatar);
    }

    final hasImage = avatar.imageUrl != null && avatar.imageUrl!.isNotEmpty;
    final hasAudio = avatar.audioUrl != null && avatar.audioUrl!.isNotEmpty;
    final hasVideo = avatar.videoUrl != null && avatar.videoUrl!.isNotEmpty;

    if (hasImage && hasAudio && hasVideo) {
      Navigator.pushReplacementNamed(context, '/chat');
    } else if (hasImage && hasAudio) {
      Navigator.pushNamed(context, '/avatar_summary');
    } else {
      Navigator.pushNamed(
        context,
        '/avatar',
        arguments: _getAvatarTypeString(type),
      );
    }
  }
  void _savePersonality(Map<String, dynamic> data) async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;
    final locale = Localizations.localeOf(context).languageCode;
    if (userId == null || _selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario no autenticado o tipo de avatar no seleccionado')));
      return;
    }

    setState(() => _isSaving = true);

    await AvatarService.saveAvatarPersonality(userId, _getAvatarTypeString(_selectedType!), {
      ...data, 
      'userLanguage': locale,
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
      'avatarType': _getAvatarTypeString(_selectedType!),
    });

    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.successSave),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
    Navigator.pushNamed(context,
     '/avatar',
     arguments: _getAvatarTypeString(_selectedType!),
     );
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
      onTap: () => _handleTypeSelection(type),
      child: Container(
        constraints: const BoxConstraints(minWidth: 140),
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
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          BannerMessage(
                            title: AppLocalizations.of(context)!.customizeYourAvatar,
                            message: AppLocalizations.of(context)!.takeAMinuteToAnswer + AppLocalizations.of(context)!.yourAnswersDefine,
                            icon: Icons.assignment_turned_in_outlined,
                          ),
                          const SizedBox(height: 20),
                          AvatarPersonalityForm(onSubmit: _savePersonality),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
