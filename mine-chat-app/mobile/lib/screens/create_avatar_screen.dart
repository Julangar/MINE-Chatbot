import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/avatar.dart';
import '../providers/avatar_provider.dart';
import '../services/avatar_service.dart';
import 'package:mine_app/l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '../widgets/banner_message.dart';

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _avatarType = ModalRoute.of(context)!.settings.arguments as String;
  }

  // Foto desde cámara
  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() => _photo = File(picked.path));
    }
  }

  // Foto desde galería
  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _photo = File(picked.path));
    }
  }

  // Video (cámara o galería)
  Future<void> _pickVideo() async {
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
    final file = await openFile(acceptedTypeGroups: [
      XTypeGroup(label: 'audio', extensions: ['mp3', 'wav', 'aac']),
    ]);
    if (file != null && file.path != null) {
      setState(() => _audio = File(file.path));
    }
  }


  // Grabar audio máximo 45 segundos
  Future<void> _startRecording() async {
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
    dynamic audioUrlCloudinary;
    dynamic audioUrl;
    dynamic videoUrl;
    // Solo sube lo que el usuario agregó
    if (_photo != null) {
      final ref = storage.ref().child('avatars/$userId/$_avatarType/image/photo.jpeg');
      await ref.putFile(_photo!);
      imageUrl = await ref.getDownloadURL();
      imageUrlCloudinary = await AvatarService.uploadImageToCloudinary(imageUrl, userId, _avatarType);
    }
    if (_audio != null) {
      final ref = storage.ref().child('avatars/$userId/$_avatarType/audio/audio.mp3');
      await ref.putFile(_audio!);
      audioUrl = await ref.getDownloadURL();
      audioUrlCloudinary = await AvatarService.uploadAudioToCloudinary(audioUrl, userId, _avatarType);
    }
    if (_video != null) {
      final ref = storage.ref().child('avatars/$userId/$_avatarType/video/video.mp4');
      await ref.putFile(_video!);
      videoUrl = await ref.getDownloadURL();
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
      'videoUrl': videoUrl,
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
        title: Text(AppLocalizations.of(context)!.createAvatar, style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF131118),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFF131118),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
              Text('${AppLocalizations.of(context)!.archive}: ${_audio!.path.split('/').last}', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),

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
