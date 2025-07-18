import 'api_service.dart';

class AvatarService {
  // Crear perfil de avatar (personalidad)
  static Future<String> createAvatar(Map<String, dynamic> data) async {
    final resp = await ApiService.post('/avatars/create', data);
    return resp['avatarId']; // Asumiendo que la respuesta es { avatarId: ... }
  }

  // Subir fotos (multipart)
  static Future<List<String>> uploadPhotos(String avatarId, List<String> filePaths) async {
    Map<String, String> files = {};
    for (var i = 0; i < filePaths.length; i++) {
      files['photos[$i]'] = filePaths[i];
    }
    final resp = await ApiService.postMultipart('/avatars/$avatarId/upload-photos', {}, files);
    return List<String>.from(resp['urls']);
  }

  // Subir audio
  static Future<String> uploadVoice(String avatarId, String audioPath) async {
    final resp = await ApiService.postMultipart('/avatars/$avatarId/upload-voice', {}, {'voice': audioPath});
    return resp['url'];
  }

  // Enviar cuestionario de personalidad
  static Future<bool> submitPersonality(String avatarId, Map<String, dynamic> data) async {
    final resp = await ApiService.post('/avatars/$avatarId/personality', data);
    return resp['success'] == true;
  }
}
