
import 'dart:convert';
import 'package:http/http.dart' as http;

class AvatarService {
  static const String baseUrl = 'http://localhost:3000'; // Cambiar en producción

  static Future<String?> generateAvatarVideo(String userId, String avatarType) async {
    final url = Uri.parse('$baseUrl/api/avatar/generate-video');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'avatarType': avatarType}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['talkId'];
    } else {
      print('Error al generar video: ${response.body}');
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
}
