import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';

import '../providers/avatar_provider.dart';
import '../services/chat_service.dart';

// Import generated localization class. This import assumes that the project
// uses the `flutter_gen` tooling to generate the localization classes from
// ARB files. If your project uses a different import path, adjust it
// accordingly. The AppLocalizations class provides access to translated
// strings defined in the .arb files.
import 'package:mine_app/l10n/app_localizations.dart';

/// Pantalla de chat mejorada.
///
/// Esta versión permite al usuario elegir el tipo de salida (texto, audio o
/// vídeo) antes de enviar un mensaje. Dependiendo de la selección, se
/// utilizan los métodos correspondientes de [ChatService] para obtener la
/// respuesta. Las respuestas se muestran en una lista de burbujas y, en el
/// caso de audio o vídeo, se reproducen automáticamente al recibirlas.
class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  late AudioPlayer _audioPlayer;
  VideoPlayerController? _videoController;

  /// Tipo de salida seleccionado por el usuario.
  ///
  /// Se utiliza una clave interna ('text', 'audio' o 'video') en lugar de la
  /// etiqueta localizada para que la lógica no dependa del idioma actual.
  String _selectedOutput = 'text';

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
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

    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'content': text, 'type': 'text'});
      _controller.clear();
      _isLoading = true;
    });

    try {
      Map<String, dynamic> data;
      // Elegir el método según la selección de salida. Utilizamos claves
      // internas ('text', 'audio' o 'video') en lugar de strings
      // localizados para mantener el flujo de control consistente.
      if (_selectedOutput == 'text') {
        data = await ChatService.sendMessage(
          avatar.userId!,
          avatar.avatarType!,
          text,
          avatar.userLanguage!,
        );
      } else if (_selectedOutput == 'audio') {
        data = await ChatService.sendAudio(
          avatar.userId!,
          avatar.avatarType!,
          text,
          avatar.userLanguage!,
        );
      } else {
        // video
        data = await ChatService.sendVideo(
          avatar.userId!,
          avatar.avatarType!,
          text,
          avatar.userLanguage!,
        );
      }

      final reply = data['response'] as String? ??
          AppLocalizations.of(context)!.noResponse;
      final audioUrl = data['audioUrl'] as String?;
      final videoUrl = data['videoUrl'] as String?;

      setState(() {
        _messages.add({
          'role': 'avatar',
          'content': reply,
          'type': _selectedOutput,
          'audioUrl': audioUrl,
          'videoUrl': videoUrl,
        });
        _isLoading = false;
      });

      // Reproducir audio si existe
      if (audioUrl != null && _selectedOutput != 'Texto') {
        await _audioPlayer.stop();
        await _audioPlayer.play(UrlSource(audioUrl));
      }

      // Reproducir vídeo si existe
      if (videoUrl != null) {
        // Liberar el controlador anterior si estaba reproduciendo algo
        await _videoController?.dispose();
        _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl))
          ..initialize().then((_) {
            setState(() {});
            _videoController!.play();
          });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.error(e.toString()),
          ),
        ),
      );
    }
  }

  Widget _buildMessage(Map<String, dynamic> msg) {
    final bool isUser = msg['role'] == 'user';
    final String type = msg['type'] as String? ?? 'text';
    Widget contentWidget;

    if (!isUser && type == 'audio' && msg['audioUrl'] != null) {
      // Mostrar un icono de audio para mensajes de audio del avatar
      contentWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.volume_up, size: 20),
          const SizedBox(width: 4),
          Text(AppLocalizations.of(context)!.audioGenerated),
        ],
      );
    } else if (!isUser && type == 'video' && msg['videoUrl'] != null) {
      // Mostrar texto indicando que se ha generado un vídeo
      contentWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.videocam, size: 20),
          const SizedBox(width: 4),
          Text(AppLocalizations.of(context)!.videoGenerated),
        ],
      );
    } else {
      // Mensaje de texto
      contentWidget = Text(
        msg['content'] ?? '',
        style: const TextStyle(fontSize: 16),
      );
    }

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue[200] : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: contentWidget,
      ),
    );
  }

  /// Muestra el reproductor de vídeo y una indicación de audio en la parte
  /// superior del chat cuando están disponibles. Se actualiza cada vez que
  /// `_videoController` cambia o cuando se reproduce un audio.
  Widget _buildAvatarMedia() {
    return Column(
      children: [
        if (_videoController != null && _videoController!.value.isInitialized)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: VideoPlayer(_videoController!),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final avatar = Provider.of<AvatarProvider>(context).avatar;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.chatTitle),
      ),
      body: Column(
        children: [
          // Mostrar vídeo si está inicializado
          _buildAvatarMedia(),
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
            child: Column(
              children: [
                // Selector de tipo de salida
                Row(
                  children: [
                    // Etiqueta y selector para el tipo de respuesta. Usamos
                    // Flexible y Expanded para evitar desbordes de texto en
                    // idiomas con etiquetas largas.
                    Flexible(
                      flex: 2,
                      child: Text(AppLocalizations.of(context)!.replyLabel),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButton<String>(
                        value: _selectedOutput,
                        isExpanded: true,
                        items: [
                          DropdownMenuItem(
                            value: 'text',
                            child: Text(
                              AppLocalizations.of(context)!.textOption,
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'audio',
                            child: Text(
                              AppLocalizations.of(context)!.audioOption,
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'video',
                            child: Text(
                              AppLocalizations.of(context)!.videoOption,
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedOutput = value;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        onSubmitted: (_) => _sendMessage(),
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.inputHint,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}