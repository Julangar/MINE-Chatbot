import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mine_chatbot/l10n/app_localizations.dart';

import '../widgets/avatar_questions/love_questions.dart';
import '../widgets/avatar_questions/friend_questions.dart';
import '../widgets/avatar_questions/relative_questions.dart';
import '../widgets/avatar_questions/myself_questions.dart';
import '../widgets/banner_message.dart';

// Modelo para enviar a Firebase (ajusta según tu backend real)
enum AvatarType { love, friend, relative, myself }

class AvatarPersonalityFormScreen extends StatefulWidget {
  const AvatarPersonalityFormScreen({Key? key}) : super(key: key);

  @override
  State<AvatarPersonalityFormScreen> createState() => _AvatarPersonalityFormScreenState();
}

class _AvatarPersonalityFormScreenState extends State<AvatarPersonalityFormScreen> {
  AvatarType? _selectedType;
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> _formData = {};
  bool _loading = false;
  bool _avatarExists = false;

  @override
  void initState() {
    super.initState();
    _checkIfAvatarExists();
  }

  Future<void> _checkIfAvatarExists() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (_selectedType != null) {
      String collectionName = _collectionForType(_selectedType!);
      final doc = await FirebaseFirestore.instance.collection(user.uid).doc(collectionName).get();
      setState(() => _avatarExists = doc.exists);
    }
  }

  String _collectionForType(AvatarType type) {
    switch (type) {
      case AvatarType.love:
        return 'love_avatars';
      case AvatarType.friend:
        return 'friend_avatars';
      case AvatarType.relative:
        return 'relative_avatars';
      case AvatarType.myself:
        return 'myself_avatars';
    }
  }

  void _onFormChanged(Map<String, dynamic> newData) {
    setState(() {
      _formData = newData;
    });
  }

  Widget _questionWidget() {
    switch (_selectedType) {
      case AvatarType.love:
        return LoveQuestions(onChanged: _onFormChanged, initialData: _formData);
      case AvatarType.friend:
        return FriendQuestions(onChanged: _onFormChanged, initialData: _formData);
      case AvatarType.relative:
        return RelativeQuestions(onChanged: _onFormChanged, initialData: _formData);
      case AvatarType.myself:
        return MyselfQuestions(onChanged: _onFormChanged, initialData: _formData);
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _saveToFirebase() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.noUserAuthenticated)),
      );
      return;
    }

    String collectionName = _collectionForType(_selectedType!);
    try {
      await FirebaseFirestore.instance
          .collection(user.uid)
          .doc(collectionName)
          .set({
            ..._formData,
            'userId': user.uid,
            'createdAt': FieldValue.serverTimestamp(),
            'type': _selectedType.toString(),
          }, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.successSave),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      await Future.delayed(const Duration(seconds: 2));
      // Navega y no permite volver a crear el avatar de este tipo
      Navigator.of(context).pushReplacementNamed('/chat');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocalizations.of(context)!.errorSaving} $e')),
      );
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.createYourAvatar, style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF131118),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: (_selectedType == null)
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  // Permite cambiar de tipo antes de guardar, borra lo seleccionado
                  setState(() {
                    _selectedType = null;
                    _formData = {};
                  });
                },
              ),
      ),
      backgroundColor: const Color(0xFF131118),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_selectedType == null)
              ? _typeSelector()
              : _avatarExists
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 60),
                          const SizedBox(height: 16),
                          Text(AppLocalizations.of(context)!.avatarAlreadyExist),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pushReplacementNamed('/chat'),
                            child: Text(AppLocalizations.of(context)!.goToChat),
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: ListView(
                          children: [
                            // BANNER FIJO
                            BannerMessage(
                              title: AppLocalizations.of(context)!.customizeYourAvatar,
                              message: AppLocalizations.of(context)!.takeAMinuteToAnswer +AppLocalizations.of(context)!.yourAnswersDefine,
                              icon: Icons.assignment_turned_in_outlined,
                            ),
                            _questionWidget(),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _loading ? null : _saveToFirebase,
                              child: Text(AppLocalizations.of(context)!.saveAndContinue),
                            ),
                          ],
                        ),
                      ),
                    ),
    );
  }

  Widget _typeSelector() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(context)!.selectAvatarType,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              _typeButton(AvatarType.love, "Love of Mine", Icons.favorite),
              _typeButton(AvatarType.friend, "Friend of Mine", Icons.people),
              _typeButton(AvatarType.relative, "Relative of Mine", Icons.family_restroom),
              _typeButton(AvatarType.myself, "Myself", Icons.person),
            ],
          ),
        ],
      ),
    );
  }

  Widget _typeButton(AvatarType type, String label, IconData icon) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(140, 50),
        textStyle: const TextStyle(fontSize: 16),
      ),
      onPressed: () async {
        setState(() {
          _selectedType = type;
          _formData = {};
          _avatarExists = false;
        });
        await _checkIfAvatarExists();
      },
    );
  }
}