import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

/// Servicio de chat para interactuar con el backend de MINE.
///
/// Este servicio encapsula las llamadas HTTP a las rutas del controlador de
/// chat. Se proporcionan métodos para enviar mensajes de texto, solicitar
/// respuestas en audio o vídeo y generar el saludo inicial. Cada método
/// devuelve el cuerpo de la respuesta decodificado como un mapa para que la
/// pantalla de chat pueda acceder a los distintos campos (por ejemplo,
/// `response`, `audioUrl` o `videoUrl`).
class ChatService {
  /// Dirección base del backend. Cambiar por la IP/host correspondiente en
  /// producción. Se ha definido como estática para que pueda ser reutilizada
  /// sin instanciar la clase.
  static const String baseUrl = 'http://192.168.1.11:3000';

  /// Solicita que el avatar se presente y salude al usuario. El back‑end
  /// devuelve un objeto JSON con la respuesta textual bajo la clave `response`.
  static Future<Map<String, dynamic>> generateGreeting(
    String userId,
    String avatarType,
    String userLanguage,
  ) async {
    final uri = Uri.parse('$baseUrl/api/chat/generate-greeting');
    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'avatarType': avatarType,
        'userLanguage': userLanguage,
      }),
    );
    if (resp.statusCode != 200) {
      throw Exception('Error al generar el saludo: ${resp.body}');
    }
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }

  /// Envía un mensaje de texto y obtiene la respuesta del avatar. El campo
  /// `userLanguage` permite indicar el idioma del usuario (por ejemplo, 'es'
  /// para español). El resultado incluye la respuesta bajo la clave `response`.
  static Future<Map<String, dynamic>> sendMessage(
    String userId,
    String avatarType,
    String message,
    String userLanguage,
  ) async {
    final uri = Uri.parse('$baseUrl/api/chat/send-message');
    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'avatarType': avatarType,
        'message': message,
        'userLanguage': userLanguage,
      }),
    );
    if (resp.statusCode != 200) {
      throw Exception('Error al obtener la respuesta: ${resp.body}');
    }
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }

  /// Solicita al back‑end que genere audio a partir del mensaje del usuario.
  /// El resultado incluye la respuesta textual y la URL del audio (`audioUrl`).
  static Future<Map<String, dynamic>> sendAudio(
    String userId,
    String avatarType,
    String message,
    String userLanguage,
  ) async {
    final uri = Uri.parse('$baseUrl/api/chat/send-audio');
    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'avatarType': avatarType,
        'message': message,
        'userLanguage': userLanguage,
      }),
    );
    if (resp.statusCode != 200) {
      throw Exception('Error al generar el audio: ${resp.body}');
    }
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }

  /// Solicita al back‑end que genere un vídeo a partir del mensaje del usuario.
  /// El resultado incluye la respuesta textual, la URL del audio y la del vídeo.
  static Future<Map<String, dynamic>> sendVideo(
    String userId,
    String avatarType,
    String message,
    String userLanguage,
  ) async {
    final uri = Uri.parse('$baseUrl/api/chat/send-video');
    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'avatarType': avatarType,
        'message': message,
        'userLanguage': userLanguage,
      }),
    );
    if (resp.statusCode != 200) {
      throw Exception('Error al generar el vídeo: ${resp.body}');
    }
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }

  static Future<String?> sendVoice(
    String userId,
    String avatarType,
    File audioFile,
    String userLanguage,
  ) async {
    final uri = Uri.parse('$baseUrl/api/chat/send-voice');
    final request = http.MultipartRequest('POST', uri)
      ..fields['userId'] = userId
      ..fields['avatarType'] = avatarType
      ..fields['userLanguage'] = userLanguage
      ..files.add(await http.MultipartFile.fromPath('audio', audioFile.path));
    final response = await request.send();
    final body = await response.stream.bytesToString();
    if (response.statusCode != 200) {
      throw Exception('Error al transcribir audio: $body');
    }
    return jsonDecode(body);
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

  /// Obtiene el historial de conversación descifrado desde el backend.
  /// Se deben proporcionar el identificador del usuario y el tipo de
  /// avatar. El servidor devolverá una lista de mensajes con las claves
  /// `userMessage` y `avatarResponse`, sin incluir URLs de audio o vídeo.
  static Future<List<dynamic>> fetchConversationHistory(
    String userId,
    String avatarType,
  ) async {
    final uri = Uri.parse(
        '$baseUrl/api/chat/history?userId=$userId&avatarType=$avatarType');
    final resp = await http.get(uri);
    if (resp.statusCode != 200) {
      throw Exception('Error al obtener el historial: ${resp.body}');
    }
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    return data['messages'] as List<dynamic>;
  }
}