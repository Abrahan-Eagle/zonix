import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:zonix/features/DomainProfiles/Documents/models/document.dart';
import 'package:logger/logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final logger = Logger();
final String baseUrl = const bool.fromEnvironment('dart.vm.product')
    ? dotenv.env['API_URL_PROD']!
    : dotenv.env['API_URL_LOCAL']!;

class DocumentService {
  final _storage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _storage.read(key: 'token');
  }

  Future<List<Document>> fetchDocuments(int id) async {
    logger.i('Fetching documents for profile ID: $id');
    final token = await _getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/api/documents/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((doc) {
        try {
          return Document.fromJson(doc);
        } catch (e) {
          logger.e('Error parsing document: $e');
          return null;
        }
      }).whereType<Document>().toList(); // Filtrar nulos correctamente
    } else {
      logger.e('Error fetching documents: ${response.statusCode} - ${response.body}');
      throw Exception('Error fetching documents: ${response.statusCode}');
    }
  }
}
