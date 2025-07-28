
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/avatar.dart';
import '../providers/avatar_provider.dart';
import '../services/avatar_service.dart';
import 'chat_screen.dart';

class AvatarSummaryScreen extends StatefulWidget {
  const AvatarSummaryScreen({super.key});

  @override
  State<AvatarSummaryScreen> createState() => _AvatarSummaryScreenState();
}

class _AvatarSummaryScreenState extends State<AvatarSummaryScreen> {
  bool _isLoading = false;
  String _statusMessage = '';

  void _generateAvatar(Avatar avatar) async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Generando avatar...';
    });

    final talkId = await AvatarService.generateAvatarVideo(avatar.userId, avatar.avatarType);

    if (talkId == null) {
      _showError('No se pudo generar el video.');
      return;
    }

    final videoUrl = await AvatarService.pollForVideoUrl(talkId);

    if (videoUrl == null) {
      _showError('El video no se generó a tiempo.');
      return;
    }

    final updated = avatar.copyWith(videoUrl: videoUrl, talkId: talkId);
    Provider.of<AvatarProvider>(context, listen: false).setAvatar(updated);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ChatScreen()),
      );
    }
  }

  void _showError(String message) {
    setState(() {
      _isLoading = false;
      _statusMessage = '';
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final avatar = Provider.of<AvatarProvider>(context).avatar;

    if (avatar == null) {
      return const Scaffold(body: Center(child: Text("Avatar no disponible")));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Resumen del Avatar')),
      body: _isLoading
          ? Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(_statusMessage),
              ],
            ))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (avatar.imageUrl != null)
                    Center(child: Image.network(avatar.imageUrl!, height: 200)),
                  const SizedBox(height: 16),
                  Text("👤 Nombre: ${avatar.name}"),
                  Text("🧑 Usuario: ${avatar.userReference}"),
                  Text("🔗 Relación: ${avatar.relationshipOrRole}"),
                  Text("🗣️ Estilo: ${avatar.speakingStyle}"),
                  Text("🎯 Intereses: ${avatar.interests.join(', ')}"),
                  Text("💬 Frases: ${avatar.commonPhrases.join(', ')}"),
                  const SizedBox(height: 8),
                  Text("🎭 Rasgos:"),
                  Text("  • Extroversión: ${avatar.traits['extroversion'] ?? 0}"),
                  Text("  • Amabilidad: ${avatar.traits['agreeableness'] ?? 0}"),
                  Text("  • Responsabilidad: ${avatar.traits['conscientiousness'] ?? 0}"),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.movie_creation_outlined),
                      label: const Text("Crear mi avatar"),
                      onPressed: () => _generateAvatar(avatar),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("← Volver a editar personalidad"),
                  )
                ],
              ),
            ),
    );
  }
}
