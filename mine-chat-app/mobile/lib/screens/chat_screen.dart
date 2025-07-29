
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/avatar.dart';
import '../providers/avatar_provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  late AudioPlayer _audioPlayer;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    final avatar = Provider.of<AvatarProvider>(context, listen: false).avatar;
    if (avatar != null && avatar.videoUrl != null) {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(avatar.videoUrl!))
        ..initialize().then((_) {
          setState(() {});
        });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final avatar = Provider.of<AvatarProvider>(context, listen: false).avatar;
    if (avatar == null) return;

    final message = _controller.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'content': message});
      _controller.clear();
      _isLoading = true;
    });

    final url = Uri.parse("http://localhost:3000/api/chat/send-message");

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': avatar.userId,
        'avatarType': avatar.avatarType,
        'message': message,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final reply = data['response'] ?? '[Empty reply]';
      setState(() {
        _messages.add({'role': 'avatar', 'content': reply});
        _isLoading = false;
      });

      // Reproducir audio si existe
      if (avatar.audioUrl != null) {
        await _audioPlayer.play(UrlSource(avatar.audioUrl!));
      }

      // Reproducir video si está listo
      if (_videoController != null && _videoController!.value.isInitialized) {
        await _videoController!.seekTo(Duration.zero);
        await _videoController!.play();
      }
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Error al comunicarse con el servidor.'),
      ));
    }
  }

  Widget _buildMessage(Map<String, String> msg) {
    final isUser = msg['role'] == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue[200] : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(msg['content'] ?? '',
            style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _buildAvatarMedia(Avatar avatar) {
    return Column(
      children: [
        if (_videoController != null && _videoController!.value.isInitialized)
          AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,
            child: VideoPlayer(_videoController!),
          ),
        if (avatar.audioUrl != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text("🎧 Audio generado"),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final avatar = Provider.of<AvatarProvider>(context).avatar;

    return Scaffold(
      appBar: AppBar(title: const Text("Chat")),
      body: Column(
        children: [
          if (avatar != null) _buildAvatarMedia(avatar),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: _messages.length,
              itemBuilder: (_, index) => _buildMessage(_messages[index]),
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: const InputDecoration(
                      hintText: "Escribe tu mensaje...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
