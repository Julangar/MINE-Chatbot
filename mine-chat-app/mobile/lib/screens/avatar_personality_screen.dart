import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widgets/avatar_questions/love_questions.dart';
import '../widgets/avatar_questions/friend_questions.dart';
import '../widgets/avatar_questions/relative_questions.dart';
import '../widgets/avatar_questions/myself_questions.dart';

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
      final doc = await FirebaseFirestore.instance.collection(collectionName).doc(user.uid).get();
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
        const SnackBar(content: Text("No hay usuario autenticado")),
      );
      return;
    }

    String collectionName = _collectionForType(_selectedType!);
    try {
      await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(user.uid)
          .set({
            ..._formData,
            'userId': user.uid,
            'createdAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Perfil guardado exitosamente!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      await Future.delayed(const Duration(seconds: 2));
      // Navega y no permite volver a crear el avatar de este tipo
      Navigator.of(context).pushReplacementNamed('/chat');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crea tu avatar"),
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
                          const Text("¡Ya tienes un avatar de este tipo!"),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pushReplacementNamed('/chat'),
                            child: const Text("Ir al chat"),
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
                            _questionWidget(),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _loading ? null : _saveToFirebase,
                              child: const Text("Guardar y continuar"),
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
          const Text(
            "Selecciona el tipo de avatar que quieres crear",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
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