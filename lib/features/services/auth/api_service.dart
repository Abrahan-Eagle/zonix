import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class ApiService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> sendTokenToBackend(String token) async {
    try {
      final response = await http.post(
        Uri.parse('https://tu-servidor.com/api/google-signin'),  // Cambia por la URL de tu backend
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storage.write(key: 'jwt', value: data['token']);  // Guardar el JWT en almacenamiento seguro
        logger.i('Inicio de sesión exitoso');
      } else {
        logger.i('Error al iniciar sesión en Laravel');
      }
    } catch (error) {
      logger.i('Error: $error');
    }
  }
}
