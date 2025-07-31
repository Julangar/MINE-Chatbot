
import 'package:flutter/material.dart';
import 'package:mine_app/l10n/app_localizations.dart';
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
    final t = AppLocalizations.of(context)!;

    setState(() {
      _isLoading = true;
      _statusMessage = t.avatar_loading_generating;
    });

    final talkId = await AvatarService.generateAvatarVideo(avatar.userId, avatar.avatarType);

    if (talkId == null) {
      _showError(t.avatar_error_video);
      return;
    }

    final videoUrl = await AvatarService.pollForVideoUrl(talkId);

    if (videoUrl == null) {
      _showError(t.avatar_error_timeout);
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
      _statusMessage = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final avatar = context.watch<AvatarProvider>().avatar;

    if (avatar == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(title: Text(t.avatar_summary_title)),
        body: Center(child: Text(t.avatar_summary_no_avatar))
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text(t.avatar_summary_title)),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(_statusMessage, style: const TextStyle(color: Colors.white)),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    avatar.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  if (avatar.imageUrl != null)
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(avatar.imageUrl!, height: 200),
                      ),
                    ),
                  const SizedBox(height: 16),
                  if (avatar.audioUrl != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Audio:", style: const TextStyle(color: Colors.white)),
                        const SizedBox(height: 8),
                        Text(avatar.audioUrl!, style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  const SizedBox(height: 16),
                  Text(t.avatar_summary_interests, style: const TextStyle(color: Colors.white)),
                  Wrap(
                    spacing: 8,
                    children: avatar.interests.map((i) => Chip(label: Text(i))).toList(),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _generateAvatar(avatar),
                    icon: const Icon(Icons.play_circle_fill),
                    label: Text(t.avatar_button_generate),
                  )
                ],
              ),
            ),
    );
  }
}
