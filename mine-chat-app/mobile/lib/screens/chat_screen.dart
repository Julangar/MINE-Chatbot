import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  late AudioPlayer _sfxPlayer; // Para efectos de sonido
  VideoPlayerController? _videoController;

  /// Tipo de salida seleccionado por el usuario.
  ///
  /// Se utiliza una clave interna ('text', 'audio' o 'video') en lugar de la
  /// etiqueta localizada para que la lógica no dependa del idioma actual.
  String _selectedOutput = 'text';

  /// Estado actual del chat: 'escuchando', 'pensando', 'hablando' o 'esperando'.
  String _status = 'esperando';

  /// Configuración para activar/desactivar vibración.
  bool _vibrationEnabled = true;

  /// Configuración para activar/desactivar sonidos de interfaz.
  bool _soundEnabled = true;

  /// Reproduce un pequeño efecto de sonido desde los recursos de la
  /// aplicación. Se espera encontrar archivos MP3 en la carpeta
  /// `assets/sounds/` y que estén declarados en `pubspec.yaml`.
  Future<void> _playEffect(String name) async {
    if (!_soundEnabled) return;
    try {
      // Detener cualquier efecto anterior antes de reproducir el nuevo
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('sounds/$name.mp3'));
    } catch (_) {
      // Si falla (por ejemplo, archivo no encontrado) no hacemos nada.
    }
  }

  /// Genera una pequeña vibración en el dispositivo si la configuración
  /// de vibración está activada.
  void _vibrate() {
    if (!_vibrationEnabled) return;
    HapticFeedback.lightImpact();
  }

  /// Cambia el estado visual del chat y desencadena vibración y sonido
  /// opcionales. El parámetro [newStatus] debe ser una de las cadenas
  /// 'escuchando', 'pensando', 'hablando' o 'esperando'.
  void _setStatus(String newStatus) {
    if (_status == newStatus) return;
    setState(() {
      _status = newStatus;
    });
    // Vibrar y reproducir sonido según el tipo de estado
    _vibrate();
    switch (newStatus) {
      case 'escuchando':
        _playEffect('listen');
        break;
      case 'pensando':
        _playEffect('thinking');
        break;
      case 'hablando':
        _playEffect('speaking');
        break;
      case 'esperando':
        _playEffect('waiting');
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
        // Cargar mensajes previos de la conversación cuando se monta la pantalla.
    _loadPreviousMessages();
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    _sfxPlayer.dispose();
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

     // Retroalimentación al enviar el mensaje
    _vibrate();
    _playEffect('send');
    // Establecer estado de pensamiento mientras esperamos la respuesta
    _setStatus('pensando');

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

      // Retroalimentación al recibir la respuesta
      _vibrate();
      _playEffect('receive');


      // Si es texto puro, volver al estado de espera. Para audio/video, el
      // estado cambiará al reproducir el contenido.
      if (audioUrl == null && videoUrl == null) {
        _setStatus('esperando');
      }

      // Reproducir audio si existe y se seleccionó el modo audio. Tras la
      // reproducción, se cambia el tipo del mensaje a texto para que no se
      // pueda reproducir nuevamente.
      if (audioUrl != null && _selectedOutput == 'audio') {
        // Índice del mensaje del avatar recién agregado. Se captura aquí para
        // poder actualizarlo después de que se complete la reproducción.
        final int msgIndex = _messages.length - 1;
        await _audioPlayer.stop();
        await _audioPlayer.play(UrlSource(audioUrl));
        // Establecer estado de habla mientras se reproduce el audio
        _setStatus('hablando');
        // Escuchar el evento de finalización de la reproducción y actualizar el
        // mensaje para mostrar solo el texto.
        _audioPlayer.onPlayerComplete.listen((event) {
          if (!mounted) return;
          setState(() {
            _messages[msgIndex]['type'] = 'text';
            _messages[msgIndex].remove('audioUrl');
          });
          // Al finalizar el audio, volver al estado de espera
          _setStatus('esperando');
        });
      }
      // Reproducir vídeo si existe
      if (videoUrl != null) {
        // Liberar el controlador anterior si estaba reproduciendo algo
        await _videoController?.dispose();
        _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
        await _videoController!.initialize();
        // Capturamos el índice del mensaje para actualizar su tipo tras la
        // reproducción del vídeo.
        final int msgIndex = _messages.length - 1;
        // Añadir un listener que cierre el vídeo al finalizar la reproducción
        // y cambie el mensaje a texto.
        late VoidCallback listener;
        listener = () {
          final controller = _videoController;
          if (controller != null &&
              controller.value.isInitialized &&
              controller.value.position >= controller.value.duration) {
            controller.pause();
            controller.seekTo(Duration.zero);
            controller.removeListener(listener);
            // Ocultar el reproductor y actualizar el mensaje
            if (mounted) {
              setState(() {
                _messages[msgIndex]['type'] = 'text';
                _messages[msgIndex].remove('audioUrl');
                _messages[msgIndex].remove('videoUrl');
                controller.dispose();
                _videoController = null;
              });
              // Al finalizar el vídeo, volver al estado de espera
              _setStatus('esperando');
            } else {
              controller.dispose();
              _videoController = null;
              // Si el widget ya no está montado, actualizamos el estado de
              // forma silenciosa sin llamar a setState ni a los callbacks
              _status = 'esperando';
            }
          }
        };
        _videoController!.addListener(listener);
        setState(() {});
        _videoController!.play();

        // Establecer estado de habla mientras se reproduce el vídeo
        _setStatus('hablando');
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
  /// Carga los mensajes guardados en Firestore para la conversación actual
  /// (usuario y tipo de avatar) y los añade a la lista local. De esta forma
  /// se pueden mostrar conversaciones previas cuando el usuario abre la
  /// pantalla. Los mensajes se ordenan cronológicamente según el campo
  /// `timestamp`.
  Future<void> _loadPreviousMessages() async {
    final avatar = Provider.of<AvatarProvider>(context, listen: false).avatar;
    if (avatar == null) return;
    final userId = avatar.userId;
    final avatarType = avatar.avatarType;
    if (userId == null || avatarType == null) return;
    try {
      // Solicitar el historial de conversación al backend. El servidor ya
      // descifra los mensajes y sólo devuelve texto plano. Audio y vídeo
      // no se incluyen por privacidad.
      final history = await ChatService.fetchConversationHistory(
        userId,
        avatarType,
      );
      final List<Map<String, dynamic>> loaded = [];
      for (final entry in history) {
        final userMsg = entry['userMessage'];
        final avatarMsg = entry['avatarResponse'];
        if (userMsg != null && userMsg is String && userMsg.isNotEmpty) {
          loaded.add({
            'role': 'user',
            'content': userMsg,
            'type': 'text',
          });
        }
        if (avatarMsg != null && avatarMsg is String && avatarMsg.isNotEmpty) {
          // Por razones de privacidad no se vuelven a mostrar audio ni vídeo en
          // conversaciones previas. Sólo se almacena el texto de la respuesta.
          loaded.add({
            'role': 'avatar',
            'content': avatarMsg,
            'type': 'text',
          });
        }
      }
      if (loaded.isNotEmpty) {
        setState(() {
          _messages.addAll(loaded);
        });
      }
    } catch (e) {
      // Si hay un error al cargar las conversaciones previas, lo registramos en consola.
      debugPrint('Error al cargar conversaciones previas: $e');
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

    /// Construye un indicador visual del estado actual del chat.
  Widget _buildStatusIndicator() {
    final loc = AppLocalizations.of(context)!;
    String text;
    switch (_status) {
      case 'escuchando':
        text = loc.statusListening;
        break;
      case 'pensando':
        text = loc.statusThinking;
        break;
      case 'hablando':
        text = loc.statusSpeaking;
        break;
      default:
        text = loc.statusWaiting;
        break;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Pequeño círculo colorido como indicador
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _status == 'esperando'
                  ? Colors.grey
                  : (_status == 'hablando'
                      ? Colors.green
                      : (_status == 'pensando'
                          ? Colors.orange
                          : Colors.blue)),
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
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
          // Indicador de estado (escuchando, pensando, hablando, esperando)
          _buildStatusIndicator(),
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
                // Controles para activar o desactivar vibración y sonidos
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context)!.enableVibration,
                            ),
                          ),
                          Switch(
                            value: _vibrationEnabled,
                            onChanged: (value) {
                              setState(() => _vibrationEnabled = value);
                            },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context)!.enableSound,
                            ),
                          ),
                          Switch(
                            value: _soundEnabled,
                            onChanged: (value) {
                              setState(() => _soundEnabled = value);
                            },
                          ),
                        ],
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