import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:zonix/features/DomainProfiles/Emails/models/email.dart';

final logger = Logger();

final String baseUrl = const bool.fromEnvironment('dart.vm.product')
    ? dotenv.env['API_URL_PROD']!
    : dotenv.env['API_URL_LOCAL']!;


class EmailService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _storage.read(key: 'token');
  }

  Future<List<Email>> fetchEmails(int id) async {
    final token = await _getToken();
    if (token == null) throw Exception('Token no encontrado.');
    
    final response = await http.get(
      Uri.parse('$baseUrl/api/emails/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Email.fromJson(e)).toList();
    } else {
      throw Exception('Error al cargar los correos: ${response.body}');
    }
  }

  Future<void> createEmail(Email email, int userId) async {
    final token = await _getToken();
      if (token == null) throw Exception('Token no encontrado.');

    final response = await http.post(
      Uri.parse('$baseUrl/api/emails'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(email.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Error al crear correo: ${response.body}');
    }
  }
Future<void> updateEmail(int id, Email email) async {
  final token = await _getToken();
  
  if (token == null) throw Exception('Token no encontrado.');

  final response = await http.put(
    Uri.parse('$baseUrl/api/emails/$id'),  // Asegúrate de que esta ruta sea correcta
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(email.toJson()),
  );

  if (response.statusCode != 200) {
    throw Exception('Error al actualizar correo: ${response.body}');
  }
}


  Future<void> deleteEmail(int id) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar correo: ${response.body}');
    }
  }
}