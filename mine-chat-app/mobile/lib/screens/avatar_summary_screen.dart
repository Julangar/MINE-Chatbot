import 'package:flutter/material.dart';
import 'package:mine_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:just_audio/just_audio.dart';

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
  String? _clonedAudioUrl;
  late AudioPlayer _originalPlayer;
  late AudioPlayer _clonedPlayer;
  VideoPlayerController? _videoController;
  bool _videoGenerated = false;

  @override
  void initState() {
    super.initState();
    _originalPlayer = AudioPlayer();
    _clonedPlayer = AudioPlayer();
    _loadClonedAudio();
  }

  Future<void> _loadClonedAudio() async {
    final avatar = context.read<AvatarProvider>().avatar;
    if (avatar == null) return;
    final url = await AvatarService.fetchClonedAudioUrl(avatar.userId, avatar.avatarType);
    setState(() {
      _clonedAudioUrl = url;
    });
  }

  Future<void> _generateAvatar(Avatar avatar) async {
    final t = AppLocalizations.of(context)!;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.warning),
        content: Text(t.avatar_generation_warning),
        actions: [
          TextButton(
            child: Text(t.cancel),
            onPressed: () => Navigator.pop(ctx, false),
          ),
          ElevatedButton(
            child: Text(t.continueText),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
      _statusMessage = t.avatar_loading_generating;
    });

    try {
      final videoUrl = await AvatarService.generateAvatarVideo(
        avatar.userId,
        avatar.avatarType,
        avatar.imageUrl!,
        _clonedAudioUrl!,
        avatar.userLanguage!,
      );

      if (videoUrl == null) {
        throw Exception(t.avatar_error_timeout);
      }

      final updated = avatar.copyWith(videoUrl: videoUrl);
      Provider.of<AvatarProvider>(context, listen: false).setAvatar(updated);

      _videoController =
          VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      await _videoController!.initialize();
      _videoController!.play();

      setState(() {
        _videoGenerated = true;
        _isLoading = false;
        _statusMessage = '';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = t.avatar_error_video;
      });
    }
  }

  @override
  void dispose() {
    _originalPlayer.dispose();
    _clonedPlayer.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final avatar = context.watch<AvatarProvider>().avatar;

    if (avatar == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(title: Text(t.avatar_summary_title)),
        body: Center(child: Text(t.avatar_summary_no_avatar)),
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
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (avatar.videoUrl != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        t.avatar_edit_locked_warning,
                        style: const TextStyle(color: Colors.black87),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(avatar.name,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  if (avatar.imageUrl != null)
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(avatar.imageUrl!, height: 200),
                      ),
                    ),
                  const SizedBox(height: 16),

                  // 🎙️ Audio original
                  if (avatar.audioUrl != null) ...[
                    Text(t.avatar_summary_original_audio, style: const TextStyle(color: Colors.white)),
                    ElevatedButton.icon(
                      onPressed: () => _originalPlayer.setUrl(avatar.audioUrl!).then((_) => _originalPlayer.play()),
                      icon: const Icon(Icons.play_arrow),
                      label: Text(t.play),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 🧠 Audio clonado
                  if (_clonedAudioUrl != null) ...[
                    Text(t.avatar_summary_cloned_audio, style: const TextStyle(color: Colors.white)),
                    ElevatedButton.icon(
                      onPressed: () => _clonedPlayer.setUrl(_clonedAudioUrl!).then((_) => _clonedPlayer.play()),
                      icon: const Icon(Icons.play_circle),
                      label: Text(t.play),
                    ),
                    const SizedBox(height: 16),
                  ],

                  Text(t.avatar_summary_interests, style: const TextStyle(color: Colors.white)),
                  Wrap(
                    spacing: 8,
                    children: avatar.interests.map((i) => Chip(label: Text(i))).toList(),
                  ),
                  const SizedBox(height: 24),

                  // 🎬 Video del avatar
                  if (_videoController != null && _videoController!.value.isInitialized) ...[
                    const SizedBox(height: 16),
                    AspectRatio(
                      aspectRatio: _videoController!.value.aspectRatio,
                      child: VideoPlayer(_videoController!),
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Botón para generar avatar si aún no hay video
                  if (!_videoGenerated && avatar.videoUrl == null)
                    ElevatedButton.icon(
                      onPressed: () => _generateAvatar(avatar),
                      icon: const Icon(Icons.smart_display),
                      label: Text(t.avatar_button_generate),
                    ),

                  // Botón para continuar al chat
                  if (avatar.videoUrl != null || _videoGenerated)
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const ChatScreen()),
                        );
                      },
                      icon: const Icon(Icons.chat),
                      label: Text(t.avatar_continue_chat),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
