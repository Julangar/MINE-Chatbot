import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mine_app/l10n/app_localizations.dart';
import '../services/avatar_service.dart';
import '../providers/avatar_provider.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _loading = true;
  List<String> _commonPhrases = [];
  List<String> _interests = [];
  String _speakingStyle = '';

  final _phraseCtrl = TextEditingController();
  final _interestCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final avatar = Provider.of<AvatarProvider>(context, listen: false).avatar;
    if (avatar == null) return;
    final data = await AvatarService.fetchPersonality(
      avatar.userId!, avatar.avatarType!,
    );
    final p = data?['personality'] as Map<String, dynamic>?;

    setState(() {
      _commonPhrases = (p?['commonPhrases'] as List?)?.cast<String>() ?? [];
      _interests = (p?['interests'] as List?)?.cast<String>() ?? [];
      _speakingStyle = (p?['speakingStyle'] as String?) ?? '';
      _loading = false;
    });
  }

  Future<void> _save() async {
    final avatar = Provider.of<AvatarProvider>(context, listen: false).avatar;
    if (avatar == null) return;
    await AvatarService.updateAllowedPersonalityFields(
      userId: avatar.userId!,
      avatarType: avatar.avatarType!,
      commonPhrases: _commonPhrases,
      interests: _interests,
      speakingStyle: _speakingStyle,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil actualizado')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final avatar = Provider.of<AvatarProvider>(context).avatar;
    final user = auth.user;

  if (!auth.isLoggedIn) {
    Future.microtask(() => Navigator.pushReplacementNamed(context, '/login'));
    return const SizedBox(); // o un loader
  }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _loading ? null : _save,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Provider.of<AuthProvider>(context, listen: false).logout();
              if (!mounted) return;
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Datos no editables
                ListTile(
                  leading: avatar?.imageUrl != null
                      ? CircleAvatar(backgroundImage: NetworkImage(avatar!.imageUrl!))
                      : const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(avatar?.name ?? 'Mi avatar'),
                  subtitle: Text('Usuario: ${avatar?.userReference ?? '—'}'),
                ),
                const SizedBox(height: 16),

                // Estilo de habla
                Text('Estilo de habla', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: _speakingStyle,
                  onChanged: (v) => _speakingStyle = v.trim(),
                  decoration: const InputDecoration(
                    hintText: 'ej. “cálido y cercano”, “directo y conciso”',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Intereses
                Text('Intereses', style: Theme.of(context).textTheme.titleMedium),
                Wrap(
                  spacing: 8,
                  children: _interests
                      .map((i) => Chip(
                            label: Text(i),
                            onDeleted: () {
                              setState(() => _interests.remove(i));
                            },
                          ))
                      .toList(),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _interestCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Añadir interés...',
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        final val = _interestCtrl.text.trim();
                        if (val.isEmpty) return;
                        setState(() {
                          _interests.add(val);
                          _interestCtrl.clear();
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Palabras frecuentes
                Text('Palabras frecuentes', style: Theme.of(context).textTheme.titleMedium),
                Wrap(
                  spacing: 8,
                  children: _commonPhrases
                      .map((p) => Chip(
                            label: Text(p),
                            onDeleted: () {
                              setState(() => _commonPhrases.remove(p));
                            },
                          ))
                      .toList(),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _phraseCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Añadir frase característica...',
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        final val = _phraseCtrl.text.trim();
                        if (val.isEmpty) return;
                        setState(() {
                          _commonPhrases.add(val);
                          _phraseCtrl.clear();
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
