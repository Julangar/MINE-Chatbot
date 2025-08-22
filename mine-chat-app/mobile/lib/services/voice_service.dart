// lib/services/voice_service.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class VoiceItem {
  final String voiceId;
  final String name;
  final String? language;
  final Map<String, dynamic> labels;
  final String? previewUrl;

  VoiceItem({required this.voiceId, required this.name, this.language, this.labels = const {}, this.previewUrl});

  factory VoiceItem.fromJson(Map<String, dynamic> j) => VoiceItem(
    voiceId: j['voiceId'],
    name: j['name'],
    language: j['language'],
    labels: (j['labels'] ?? {}) as Map<String, dynamic>,
    previewUrl: j['previewUrl'],
  );
}

class VoiceService {
  VoiceService(this.baseUrl);
  final String baseUrl;

  Future<List<VoiceItem>> fetchVoices({String? lang, int limit = 50}) async {
    final q = <String>[];
    if (lang != null && lang.isNotEmpty) q.add('lang=$lang');
    if (limit > 0) q.add('limit=$limit');
    final uri = Uri.parse('$baseUrl/api/voices${q.isEmpty ? '' : '?${q.join('&')}'}');
    final r = await http.get(uri);
    if (r.statusCode != 200) throw Exception('Error obteniendo voces: ${r.body}');
    final data = jsonDecode(r.body);
    final list = (data['voices'] as List).map((e) => VoiceItem.fromJson(e)).toList();
    return list;
  }

  /// Devuelve bytes mp3 (o base64) para pre‑escuchar una frase corta con esa voz
  Future<Uint8List> previewTts(String voiceId, {String text = 'Hola, soy tu nuevo avatar.'}) async {
    final uri = Uri.parse('$baseUrl/api/voices/preview');
    final r = await http.post(uri, headers: {'Content-Type':'application/json'}, body: jsonEncode({'voiceId': voiceId, 'text': text}));
    if (r.statusCode != 200) throw Exception('Error preview TTS: ${r.body}');
    final data = jsonDecode(r.body);
    if (data['base64'] != null) {
      return base64Decode(data['base64']);
    }
    throw Exception('Respuesta preview sin base64');
  }
}
