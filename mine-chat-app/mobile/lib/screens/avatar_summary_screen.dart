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

  @override
  void initState() {
    super.initState();
    _originalPlayer = AudioPlayer();
    _clonedPlayer = AudioPlayer();
    _loadClonedAudio();
  }

  @override
  void dispose() {
    _originalPlayer.dispose();
    _clonedPlayer.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _loadClonedAudio() async {
    final avatar = context.read<AvatarProvider>().avatar;
    if (avatar != null) {
      final url = await AvatarService.fetchClonedAudioUrl(avatar.userId, avatar.avatarType);
      setState(() => _clonedAudioUrl = url);
    }
  }

  Future<void> _generateAvatar(Avatar avatar) async {
    final t = AppLocalizations.of(context)!;

    setState(() {
      _isLoading = true;
      _statusMessage = t.avatar_loading_generating;
    });

    final talkId = await AvatarService.generateAvatarVideo(
      avatar.userId,
      avatar.avatarType,
      avatar.imageUrl!,
      avatar.audioUrl!,
      avatar.userLanguage!,
    );

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

  Widget _audioPlayer(AudioPlayer player, String url, String label) {
    player.setUrl(url);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white)),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.play_arrow, color: Colors.green),
              onPressed: () => player.play(),
            ),
            IconButton(
              icon: const Icon(Icons.stop, color: Colors.red),
              onPressed: () => player.stop(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _videoPlayer(String url) {
    _videoController = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize().then((_) {
        setState(() {});
        _videoController!.play();
      });
    return _videoController!.value.isInitialized
        ? AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,
            child: VideoPlayer(_videoController!),
          )
        : const CircularProgressIndicator();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final avatar = context.watch<AvatarProvider>().avatar;

    if (avatar == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(title: Text(t.avatar_summary_title)),
        body: Center(child: Text(t.avatar_summary_no_avatar, style: const TextStyle(color: Colors.white))),
      );
    }

    final canGenerate = avatar.videoUrl == null;

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
              child: ListView(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[800],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      t.avatar_warning_edit_locked,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12),
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
                    _audioPlayer(_originalPlayer, avatar.audioUrl!, t.avatar_original_audio),
                  const SizedBox(height: 12),
                  if (_clonedAudioUrl != null)
                    _audioPlayer(_clonedPlayer, _clonedAudioUrl!, t.avatar_cloned_audio),
                  const SizedBox(height: 16),
                  Text(t.avatar_summary_interests, style: const TextStyle(color: Colors.white)),
                  Wrap(
                    spacing: 8,
                    children: avatar.interests.map((i) => Chip(label: Text(i))).toList(),
                  ),
                  const SizedBox(height: 16),
                  if (avatar.videoUrl != null)
                    Column(
                      children: [
                        Text(t.avatar_video_result, style: const TextStyle(color: Colors.white)),
                        const SizedBox(height: 12),
                        _videoPlayer(avatar.videoUrl!),
                      ],
                    ),
                  const SizedBox(height: 24),
                  if (canGenerate)
                    ElevatedButton.icon(
                      onPressed: () => _generateAvatar(avatar),
                      icon: const Icon(Icons.play_circle_fill),
                      label: Text(t.avatar_button_generate),
                    ),
                ],
              ),
            ),
    );
  }
}
