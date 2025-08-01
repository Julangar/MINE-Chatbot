
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
      final promptResponse = await http.post(
        Uri.parse('$baseUrl/api/avatar/generate-greeting'),
        body: jsonEncode({'language': language}),
        headers: {'Content-Type': 'application/json'},
      );

      final prompt = jsonDecode(promptResponse.body)['message'];

      final voiceResponse = await http.post(
        Uri.parse('$baseUrl/api/avatar/generate-voice'),
        body: jsonEncode({'text': prompt, 'voiceId': voiceId}),
        headers: {'Content-Type': 'application/json'},
      );

      final clonedVoiceUrl = jsonDecode(voiceResponse.body)['voiceUrl'];

      final videoResponse = await http.post(
        Uri.parse('$baseUrl/api/avatar/video'),
        body: jsonEncode({
          'imageUrl': imageUrl,
          'audioUrl': clonedVoiceUrl,
          'type': avatarType,
          'language': language,
          'userId': userId,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (videoResponse.statusCode == 200) {
        return jsonDecode(videoResponse.body)['videoUrl'];
      } else {
        print("Error: ${videoResponse.body}");
        return null;
      }
    } catch (e) {
      print("Error general: $e");
      return null;
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
