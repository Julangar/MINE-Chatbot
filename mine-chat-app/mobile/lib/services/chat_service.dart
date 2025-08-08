import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class ChatService {
  static const String baseUrl = 'http://192.168.1.11:3000'; // Cambiar en producción

  static Future<String?> generateConversation(
      String userId,
      String avatarType,
      String message
  ) async {
    try {

      final promptResponse = await http.post(
        Uri.parse('$baseUrl/api/chat/send-message'),
        body: jsonEncode({
          'userId': userId,
          'avatarType': avatarType,
          'message': message,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (promptResponse.statusCode != 200) {
        throw Exception("Error al generar el saludo: ${promptResponse.body}");
      }

      final prompt = jsonDecode(promptResponse.body)['message'];

    } catch (e) {
      throw Exception("Error general: $e");
    }
  }
  static Future<String?> generateAudio(
      String userId,
      String avatarType,
      String message
  ) async {
    try {
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

      final clonedVoiceUrl = jsonDecode(voiceResponse.body)['voiceUrl'];

    } catch (e) {
      throw Exception("Error general: $e");
    }
  }
  static Future<String?> generateVideo(
      String userId,
      String avatarType,
      String message
  ) async {
    try {
      final videoResponse = await http.post(
        Uri.parse('$baseUrl/api/avatar/generate-video-audio'),
        body: jsonEncode({
          'userId': userId,
          'avatarType': avatarType,   
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




  static Future<String?> fetchClonedAudioUrl(String userId, String avatarType) async {
    final doc = await FirebaseFirestore.instance
        .collection('avatars')
        .doc(userId)
        .collection(avatarType)
        .doc('audioClone')
        .get();
    return doc.data()?['audioUrl'];
  }

  static Future<String> fetchVideoUrl(String userId, String avatarType) async {
    final doc = await FirebaseFirestore.instance
        .collection('avatars')
        .doc(userId)
        .collection(avatarType)
        .doc('video')
        .get();
    return doc.data()?['videoUrl'];
  }

}
