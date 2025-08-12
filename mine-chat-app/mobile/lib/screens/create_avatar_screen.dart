import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/avatar.dart';
import '../providers/avatar_provider.dart';
import '../services/avatar_service.dart';
import 'package:mine_app/l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
// Para recorte de imágenes
import 'package:image_cropper/image_cropper.dart';
// Para reproducción de audio de previsualización
import 'package:audioplayers/audioplayers.dart';
import 'package:file_selector/file_selector.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '../widgets/banner_message.dart';

// Gestión de permisos en tiempo de ejecución
import 'package:permission_handler/permission_handler.dart';

// Future: audio trimming functionality could be added using packages like
// `audio_trimmer` or `ffmpeg_kit_flutter`. For now we only provide playback
// controls and a progress slider so the user can review their recording.

class CreateAvatarScreen extends StatefulWidget {
  const CreateAvatarScreen({super.key});

  @override
  State<CreateAvatarScreen> createState() => _CreateAvatarScreenState();
}

class _CreateAvatarScreenState extends State<CreateAvatarScreen> {
  File? _photo;
  File? _audio;
  File? _video;
  bool _isRecording = false;
  bool _loading = false;
  final AudioRecorder _recorder = AudioRecorder();
  late String _avatarType;

  // Reproductor para previsualizar el audio subido
  AudioPlayer? _audioPreviewPlayer;
  Duration _audioDuration = Duration.zero;
  Duration _audioPosition = Duration.zero;
  bool _isPlayingAudio = false;

  /// Solicita un permiso y muestra un SnackBar si no se concede. Devuelve
  /// `true` si el permiso fue otorgado, de lo contrario `false`.
  Future<bool> _ensurePermission(Permission permission, String message) async {
    final status = await permission.request();
    if (status == PermissionStatus.granted) {
      return true;
    }
    if (!mounted) return false;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
    return false;
  }

  /// Devuelve el permiso correcto para acceder a la galería según la
  /// plataforma. En iOS es [Permission.photos] y en Android [Permission.storage].
  Permission _galleryPermission() {
    if (Platform.isIOS) {
      return Permission.photos;
    }
    return Permission.storage;
  }

  // Campos para control de recorte de audio (inicio y fin en milisegundos). En
  // esta implementación se usan únicamente para mostrar una vista previa
  // interactiva; recortes efectivos podrían realizarse en el servidor o con
  // bibliotecas adicionales.
  double _audioTrimStartMs = 0;
  double _audioTrimEndMs = 0;

  /// Devuelve un widget con la guía para que el usuario cargue correctamente
  /// los recursos de su avatar. Los textos se extraen de las localizaciones
  /// para permitir traducción. Se recomienda colocar esta guía al inicio de
  /// la pantalla para que el usuario la lea antes de subir archivos.
  Widget _buildGuidelines() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2238),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.avatarGuideTitle,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Guía para imagen
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.image, size: 20, color: Color(0xFF5619e5)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.avatarGuideImage,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Guía para audio
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.mic, size: 20, color: Color(0xFF5619e5)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.avatarGuideAudio,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Guía para video
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.videocam, size: 20, color: Color(0xFF5619e5)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.avatarGuideVideo,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Devuelve una cadena en formato m:ss a partir de un [Duration].
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(1, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Construye la interfaz de previsualización del audio con controles de
  /// reproducción y una barra deslizante. Si no hay audio seleccionado,
  /// devuelve un contenedor vacío. El recorte de audio no se realiza en esta
  /// función; sin embargo, la posición de inicio y fin se registra para
  /// futuras mejoras (p. ej., recorte en el servidor).
  Widget _buildAudioPreview() {
    if (_audio == null || _audioPreviewPlayer == null) {
      return const SizedBox.shrink();
    }
    final max = _audioDuration.inMilliseconds.toDouble();
    final position = _audioPosition.inMilliseconds.toDouble().clamp(0.0, max);
    // Asegurar que los límites de recorte se ajusten a la duración actual
    _audioTrimEndMs = max;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: Icon(_isPlayingAudio ? Icons.pause : Icons.play_arrow),
              color: Colors.white,
              onPressed: _toggleAudioPlayback,
            ),
            Expanded(
              child: Slider(
                min: 0,
                max: max > 0 ? max : 1,
                value: position,
                activeColor: const Color(0xFF5619e5),
                inactiveColor: Colors.white24,
                onChanged: (value) async {
                  final newPos = Duration(milliseconds: value.toInt());
                  await _audioPreviewPlayer?.seek(newPos);
                },
              ),
            ),
            Text(
              '${_formatDuration(Duration(milliseconds: position.toInt()))} / ${_formatDuration(_audioDuration)}',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // Información sobre recorte (no funcional en esta versión)
        Text(
          AppLocalizations.of(context)!.audioPreviewInfo,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }

  /// Permite recortar una imagen seleccionada para ajustar el rostro. Utiliza
  /// image_cropper para mostrar una interfaz nativa de recorte. Devuelve un
  /// [File] con la imagen recortada o null si el usuario cancela.
  Future<File?> _cropImage(File imageFile) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      compressQuality: 85,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Recortar imagen',
          toolbarColor: const Color(0xFF131118),
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: false,
          aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio4x3,
        ],
        ),
        IOSUiSettings(
          title: 'Recortar imagen',
          aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio4x3,
        ],
        ),
      ],
    );
    if (croppedFile != null) {
      return croppedFile != null ? File(croppedFile.path) : null;
    }
    return null;
  }

  /// Inicializa el reproductor de previsualización de audio cuando el usuario
  /// selecciona o graba un archivo de audio. Obtiene la duración del audio y
  /// establece los listeners para actualizar la posición de reproducción.
  Future<void> _setupAudioPreview(File audioFile) async {
    // Libera el reproductor anterior
    await _audioPreviewPlayer?.dispose();
    final player = AudioPlayer();
    _audioPreviewPlayer = player;

    // Escucha la duración cuando el reproductor la emita
    player.onDurationChanged.listen((duration) {
      setState(() {
        _audioDuration = duration;
      });
    });

    // Escucha la posición para actualizar la barra de progreso
    player.onPositionChanged.listen((pos) {
      setState(() {
        _audioPosition = pos;
      });
    });

    player.onPlayerComplete.listen((_) {
      setState(() {
        _isPlayingAudio = false;
        _audioPosition = _audioDuration;
      });
    });

    // Establece la fuente. Este método ya no devuelve Duration.
    await player.setSource(DeviceFileSource(audioFile.path));

    // También puedes consultar la duración directamente:
    final duration = await player.getDuration();
    if (duration != null) {
      setState(() {
        _audioDuration = duration;
      });
    }
  }
  /// Controla la reproducción y pausa del audio en la previsualización.
  Future<void> _toggleAudioPlayback() async {
    final player = _audioPreviewPlayer;
    if (player == null) return;
    if (_isPlayingAudio) {
      await player.pause();
      setState(() => _isPlayingAudio = false);
    } else {
      await player.play(player.source!);
      setState(() => _isPlayingAudio = true);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _avatarType = ModalRoute.of(context)!.settings.arguments as String;
  }

  // Foto desde cámara
  Future<void> _takePhoto() async {
    // Solicitar permiso de cámara antes de intentar abrirla
    final hasCamera = await _ensurePermission(
      Permission.camera,
      AppLocalizations.of(context)!.cameraPermissionDenied,
    );
    if (!hasCamera) return;
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      File selected = File(picked.path);
      // Permitir recorte de la imagen
      final cropped = await _cropImage(selected);
      if (cropped != null) {
        selected = cropped;
      }
      setState(() => _photo = selected);
    }
  }

  // Foto desde galería
  Future<void> _pickPhoto() async {
    // Solicitar permiso de almacenamiento/fotos según plataforma
    final galleryPerm = _galleryPermission();
    final hasStorage = await _ensurePermission(
      galleryPerm,
      AppLocalizations.of(context)!.storagePermissionDenied,
    );
    if (!hasStorage) return;
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      File selected = File(picked.path);
      // Permitir recorte de la imagen
      final cropped = await _cropImage(selected);
      if (cropped != null) {
        selected = cropped;
      }
      setState(() => _photo = selected);
    }
  }

  // Video (cámara o galería)
  Future<void> _pickVideo() async {
    // Solicitar permisos relevantes: cámara y micrófono para grabar,
    // almacenamiento para seleccionar desde la galería
    final hasCamera = await _ensurePermission(
      Permission.camera,
      AppLocalizations.of(context)!.cameraPermissionDenied,
    );
    final hasMicrophone = await _ensurePermission(
      Permission.microphone,
      AppLocalizations.of(context)!.microphonePermissionDenied,
    );
    final galleryPerm = _galleryPermission();
    final hasStorage = await _ensurePermission(
      galleryPerm,
      AppLocalizations.of(context)!.storagePermissionDenied,
    );
    if (!hasCamera || !hasMicrophone || !hasStorage) return;
    final picker = ImagePicker();
    final picked = await showModalBottomSheet<XFile?>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.videocam),
              title: Text(AppLocalizations.of(context)!.recordVideo),
              onTap: () async {
                final video = await picker.pickVideo(source: ImageSource.camera);
                Navigator.pop(ctx, video);
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_library),
              title: Text(AppLocalizations.of(context)!.chooseFromGallery),
              onTap: () async {
                final video = await picker.pickVideo(source: ImageSource.gallery);
                Navigator.pop(ctx, video);
              },
            ),
          ],
        ),
      ),
    );
    if (picked != null) {
      setState(() => _video = File(picked.path));
    }
  }

  // Audio (solo selector)
  Future<void> _pickAudio() async {
    // Solicitar permiso de almacenamiento para acceder a archivos
    final galleryPerm = _galleryPermission();
    final hasStorage = await _ensurePermission(
      galleryPerm,
      AppLocalizations.of(context)!.storagePermissionDenied,
    );
    if (!hasStorage) return;
    final file = await openFile(acceptedTypeGroups: [
      XTypeGroup(label: 'audio', extensions: ['mp3', 'wav', 'aac']),
    ]);
    if (file != null && file.path != null) {
      final selected = File(file.path);
      setState(() => _audio = selected);
      // Inicializar la previsualización del audio
      await _setupAudioPreview(selected);
    }
  }


  // Grabar audio máximo 45 segundos
  Future<void> _startRecording() async {
    // Solicitar permiso de micrófono antes de grabar
    final hasMic = await _ensurePermission(
      Permission.microphone,
      AppLocalizations.of(context)!.microphonePermissionDenied,
    );
    if (!hasMic) return;
    if (await _recorder.hasPermission()) {
      Directory tempDir = await getTemporaryDirectory();
      String filePath = '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _recorder.start(const RecordConfig(), path: filePath);

      setState(() {
        _isRecording = true;
      });

      // Detener grabación automáticamente a los 45 segundos
      Future.delayed(const Duration(seconds: 45), () async {
        if (_isRecording) {
          await _stopRecording();
        }
      });
    }
  }

  // Detener grabación manualmente o automático
  Future<void> _stopRecording() async {
    final path = await _recorder.stop();
    setState(() {
      _isRecording = false;
      if (path != null) _audio = File(path);
    });
    if (path != null) {
      await _setupAudioPreview(File(path));
    }
  }
  // Botón para grabar o parar
  Widget _audioRecorderButton() {
    return Flexible(
      child: ElevatedButton.icon(
        onPressed: _isRecording ? _stopRecording : _startRecording,
        icon: Icon(_isRecording ? Icons.stop : Icons.mic),
        label: Text(_isRecording ? AppLocalizations.of(context)!.stop : AppLocalizations.of(context)!.record45),
        style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 191, 62, 53),padding: const EdgeInsets.symmetric(horizontal: 8)),
      )
    );
  }
  // Upload files to Firebase
  Future<void> _uploadAll() async {
    setState(() => _loading = true);
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid; 

    if (userId == null) {
      // Maneja el error de no tener usuario logueado
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.noUserAuthenticated)),
      );
      return;
    }
    final storage = FirebaseStorage.instanceFor(
      bucket: "mine-app-test"
    );
    dynamic imageUrl;
    dynamic imageUrlCloudinary;
    dynamic audioUrl;
    dynamic audioUrlCloudinary;
    dynamic videoUrl;
    dynamic videoUrlCloudinary;

    // Comprobar duración mínima del audio
    if (_audio != null && _audioDuration.inSeconds < 15) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.audioTooShort),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Preparar tareas de subida concurrentes
    List<Future<void>> uploadTasks = [];
    if (_photo != null) {
      uploadTasks.add(() async {
        final ref = storage.ref().child('avatars/$userId/$_avatarType/image/photo.jpeg');
        await ref.putFile(_photo!);
        final url = await ref.getDownloadURL();
        final urlCloud = await AvatarService.uploadImageToCloudinary(url, userId, _avatarType);
        imageUrl = url;
        imageUrlCloudinary = urlCloud;
      }());
    }
    if (_audio != null) {
      uploadTasks.add(() async {
        final ref = storage.ref().child('avatars/$userId/$_avatarType/audio/audio.mp3');
        await ref.putFile(_audio!);
        final url = await ref.getDownloadURL();
        final urlCloud = await AvatarService.uploadAudioToCloudinary(url, userId, _avatarType);
        audioUrl = url;
        audioUrlCloudinary = urlCloud;
      }());
    }
    if (_video != null) {
      uploadTasks.add(() async {
        final ref = storage.ref().child('avatars/$userId/$_avatarType/video/video.mp4');
        await ref.putFile(_video!);
        final url = await ref.getDownloadURL();
        final urlCloud = await AvatarService.uploadVideoToCloudinary(url, userId, _avatarType);
        videoUrl = url;
        videoUrlCloudinary = urlCloud;
      }());
    }
    // Esperar a que todas las tareas se completen
    await Future.wait(uploadTasks);

    // Tras cargar archivos a Firebase y Cloudinary, iniciar procesos
    // adicionales según la combinación de medios enviada. Esto incluye
    // clonar la voz con ElevenLabs en el backend. 
    // Estas funciones deben estar implementadas en
    // AvatarService (p. ej. cloneVoice). Si
    // no están disponibles, se omitirán silenciosamente.
    try {
      if (_audio != null && _photo != null) {
        // El usuario subió imagen y audio (y posiblemente video). Se clona la
        // voz para usarla mas adelante.
        await AvatarService.cloneVoice(
          audioUrlCloudinary,
          userId,
          _avatarType,
        );
      }
    } catch (e) {
      // Ignorar errores de generación; se podrán consultar en la pantalla de
      // resumen del avatar. Se imprime en consola para depuración.
      debugPrint('Error al clonar la voz: $e');
    }

    setState(() => _loading = false);
    final doc = await FirebaseFirestore.instance
      .collection('avatars')
      .doc(userId)
      .collection(_avatarType)
      .doc('personality')
      .get();

    await FirebaseFirestore.instance
    .collection('avatars')
    .doc(userId)
    .collection(_avatarType)
    .doc('personality').update({
      'imageUrl': imageUrlCloudinary,
      'audioUrl': audioUrlCloudinary,
      'videoUrl': videoUrlCloudinary,
    });
    final data = doc.data() ?? {};

    final avatar = Avatar(
      userId: userId,
      avatarType: _avatarType,
      name: data['name'] ?? '',
      country: data['country'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      speakingStyle: data['speakingStyle'] ?? '',
      commonPhrases: List<String>.from(data['commonPhrases'] ?? []),
      traits: Map<String, double>.from(data['traits'] ?? {}),
      interests: List<String>.from(data['interests'] ?? []),
      relationshipOrRole: data['relationshipOrRole'] ?? '',
      userReference: data['userReference'] ?? '',
      imageUrl: imageUrl,
      audioUrl: audioUrl,
      videoUrl: videoUrl,
      talkId: null,
      userLanguage: data['userLanguage'] ?? '',
    );

    Provider.of<AvatarProvider>(context, listen: false).setAvatar(avatar);
    // Puedes mostrar un mensaje de éxito aquí o navegar a otra pantalla
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.successUpload),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // Esperar 2 segundos para que el usuario vea el mensaje
      await Future.delayed(const Duration(seconds: 2));

    // Navegar a la ruta '/avatar_summary' después de subir los archivos
      Navigator.pushNamed(context, '/avatar_summary');

    // O puedes usar Navigator.pushReplacementNamed si no quieres que el usuario vuelva a esta pantalla
    // Navigator.pushReplacementNamed(context, '/avatar_personality');
   }
  }

  @override
  Widget build(BuildContext context) {
    // Habilita el botón si: (hay al menos 1 foto y 1 audio) O hay video
    final canContinue = (!_loading && _photo != null && _audio != null) || (!_loading && _video != null);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.createAvatar, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF131118),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFF131118),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Guía de carga de avatar
            _buildGuidelines(),
            // Mensaje de banner original de la app
            BannerMessage(
              title: AppLocalizations.of(context)!.takeYourTime,
              message: AppLocalizations.of(context)!.carefullySelect,
              icon: Icons.info_outline,
            ),
            // FOTO
            Row(
              children: [
                Text('${AppLocalizations.of(context)!.photo}:', style: const TextStyle(color: Colors.white)),
                const Spacer(),
                Flexible(
                  child: ElevatedButton(
                    onPressed: _takePhoto,                   
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
                    child: Text(AppLocalizations.of(context)!.takePhoto),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: ElevatedButton(
                    onPressed: _pickPhoto,                    
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
                    child: Text(AppLocalizations.of(context)!.gallery),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
            if (_photo != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Stack(
                  children: [
                    Image.file(_photo!, width: 96, height: 96, fit: BoxFit.cover),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: GestureDetector(
                        onTap: () => setState(() => _photo = null),
                        child: const CircleAvatar(radius: 12, backgroundColor: Colors.red, child: Icon(Icons.close, size: 16, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // AUDIO
            Row(
              children: [
                Text('${AppLocalizations.of(context)!.audio}:', style: const TextStyle(color: Colors.white)),
                const Spacer(),
                _audioRecorderButton(),
                const SizedBox(width: 8),
                Flexible(
                  child: ElevatedButton.icon(
                    onPressed: _pickAudio,
                    icon: const Icon(Icons.upload_file, size: 18),
                    label: Text(_audio == null ? AppLocalizations.of(context)!.uploadAudio : AppLocalizations.of(context)!.change),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
            if (_audio != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0, bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${AppLocalizations.of(context)!.archive}: ${_audio!.path.split('/').last}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    _buildAudioPreview(),
                  ],
                ),
              ),
            if (_audio == null) const SizedBox(height: 16),

            // VIDEO
            Row(
              children: [
                Text('${AppLocalizations.of(context)!.video}:', style: const TextStyle(color: Colors.white)),
                if (_video != null) const Icon(Icons.check, color: Colors.green),
                const Spacer(),
                Flexible(
                child: ElevatedButton(
                  onPressed: _pickVideo,                  
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
                  child: Text(_video == null ? AppLocalizations.of(context)!.uploadVideo : AppLocalizations.of(context)!.change),
                ),
              ),
              const SizedBox(width: 8),     
              ],
            ),
            if (_video != null)
              Text('${AppLocalizations.of(context)!.video}: ${_video!.path.split('/').last}', style: const TextStyle(color: Colors.white70)),
            const Spacer(),

            // BOTÓN GUARDAR Y CONTINUAR
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: canContinue ? const Color(0xFF5619e5) : Colors.grey,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                ),
                onPressed: canContinue ? _uploadAll : null,
                child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(AppLocalizations.of(context)!.saveAndContinue, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.chooseAvatarInstruction,
              style: const TextStyle(color: Color(0xFFa59db8), fontSize: 14), textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
