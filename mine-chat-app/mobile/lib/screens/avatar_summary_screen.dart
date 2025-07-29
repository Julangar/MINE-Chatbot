
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
      _statusMessage = '';
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final avatar = Provider.of<AvatarProvider>(context).avatar;

    if (avatar == null) {
      return Scaffold(body: Center(child: Text(t.avatar_not_available)));
    }

    return Scaffold(
      appBar: AppBar(title: Text(t.avatar_summary_title)),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(_statusMessage),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (avatar.imageUrl != null)
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(avatar.imageUrl!, height: 200),
                      ),
                    ),
                  const SizedBox(height: 20),
                  Text("👤 ${avatar.name}", style: Theme.of(context).textTheme.bodyLarge),
                  Text("🧑 ${t.avatar_summary_user}: ${avatar.userReference}"),
                  Text("🔗 ${t.avatar_summary_relationship}: ${avatar.relationshipOrRole}"),
                  Text("🗣️ ${t.avatar_summary_style}: ${avatar.speakingStyle}"),
                  Text("🎯 ${t.avatar_summary_interests}: ${avatar.interests.join(', ')}"),
                  Text("💬 ${t.avatar_summary_phrases}: ${avatar.commonPhrases.join(', ')}"),
                  const SizedBox(height: 12),
                  Text("🎭 ${t.avatar_summary_traits}:", style: Theme.of(context).textTheme.titleMedium),
                  Text("• ${t.avatar_summary_extroversion}: ${avatar.traits['extroversion'] ?? 0}"),
                  Text("• ${t.avatar_summary_agreeableness}: ${avatar.traits['agreeableness'] ?? 0}"),
                  Text("• ${t.avatar_summary_conscientiousness}: ${avatar.traits['conscientiousness'] ?? 0}"),
                  const SizedBox(height: 32),
                  Center(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.movie_creation_outlined),
                      label: Text(t.avatar_summary_create_button),
                      onPressed: () => _generateAvatar(avatar),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: Text(t.avatar_summary_back_button),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
