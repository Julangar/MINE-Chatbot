import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://tu-backend.com/api";

  static Future<dynamic> post(String endpoint, Map<String, dynamic> data,
      {Map<String, String>? headers}) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers ?? {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Error: ${response.body}');
    }
  }

  static Future<dynamic> postMultipart(
    String endpoint,
    Map<String, String> fields,
    Map<String, String> filePaths, // {"photo": "/path/file.jpg"}
    {Map<String, String>? headers}
  ) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl$endpoint'),
    );
    request.fields.addAll(fields);
    for (final entry in filePaths.entries) {
      final multipartFile = await http.MultipartFile.fromPath(entry.key, entry.value);
      request.files.add(multipartFile);
    }
    if (headers != null) request.headers.addAll(headers);
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Error: ${response.body}');
    }
  }
}
