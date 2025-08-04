import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class AvatarService {
  static const String baseUrl = 'http://192.168.1.11:3000'; // Cambiar en producción

  static Future<String?> generateAvatarVideo(
      String userId,
      String avatarType,
      String imageUrl,
      String voiceId,
      String language,
  ) async {
    try {
      // Paso 0: Clonar la voz si es necesario
      final cloneResponse = await http.post(
        Uri.parse('$baseUrl/api/avatar/clone-voice'),
        body: jsonEncode({
          'audioUrl': voiceId, // Esto debe ser la URL del audio subido
          'userId': userId,
          'avatarType': avatarType,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (cloneResponse.statusCode != 200) {
        throw Exception("Error al clonar la voz: ${cloneResponse.body}");
      }

      final promptResponse = await http.post(
        Uri.parse('$baseUrl/api/avatar/generate-greeting'),
        body: jsonEncode({
          'userId': userId,
          'avatarType': avatarType,
          'language': language,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (promptResponse.statusCode != 200) {
        throw Exception("Error al generar el saludo: ${promptResponse.body}");
      }

      //final prompt = jsonDecode(promptResponse.body)['message'];

      final voiceResponse = await http.post(
        Uri.parse('$baseUrl/api/avatar/generate-voice'),
        body: jsonEncode({
          'userId': userId,
          'avatarType': avatarType,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (voiceResponse.statusCode != 200) {
        throw Exception("Error al generar la voz: ${voiceResponse.body}");
      }

      //final clonedVoiceUrl = jsonDecode(voiceResponse.body)['voiceUrl'];

      final videoResponse = await http.post(
        Uri.parse('$baseUrl/api/avatar/generate-video'),
        body: jsonEncode({
          'userId': userId,
          'avatarType': avatarType,
          'language': language,    
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (videoResponse.statusCode == 200) {
        return jsonDecode(videoResponse.body)['videoUrl'];
      } else {
        throw Exception("Error: ${videoResponse.body}");
      }
    } catch (e) {
      throw Exception("Error general: $e");
    }
  }


  static Future<String?> pollForVideoUrl(String talkId, {int maxRetries = 10, Duration interval = const Duration(seconds: 5)}) async {
    final url = Uri.parse('$baseUrl/api/avatar/video-status/$talkId');

    for (int i = 0; i < maxRetries; i++) {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ready'] == true && data['videoUrl'] != null) {
          return data['videoUrl'];
        }
      } else {
        print('Error al verificar estado del video: ${response.body}');
      }

      await Future.delayed(interval);
    }

    return null;
  }

static Future<String?> fetchClonedAudioUrl(String userId, String avatarType) async {
    final doc = await FirebaseFirestore.instance
        .collection('avatars')
        .doc(userId)
        .collection(avatarType)
        .doc('audioClone')
        .get();
    return doc.data()?['audioUrl'];
  }

  static Future<void> saveAvatarPersonality(
    String userId, String avatarType, Map<String, dynamic> data) async {
    final docRef = FirebaseFirestore.instance
    .collection('avatars')
    .doc(userId)
    .collection(avatarType)
    .doc('personality');

    await docRef.set(data);
  }
}
