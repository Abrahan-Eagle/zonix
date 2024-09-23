import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class ApiService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> sendTokenToBackend(String? result) async {
    if (result == null) {
      logger.e('Error: el data es null');
      return;
    }

    final decodedData = jsonDecode(result); // Decodificar el JSON

    try {
      final body = jsonEncode({
        'success': true,
        'token': decodedData['token'],
        'data': decodedData['profile'],
        'message': 'Datos recibidos correctamente.',
      });

      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/auth/google'), // Cambia por la URL de tu backend
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'flutter/1.0',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        var $varToken = responseData['token'];
        logger.i($varToken);

        // Verificación más flexible para data
        if ($varToken != null) {
          await _storage.write(key: 'token', value: responseData['token']);  // Guardar el JWT en almacenamiento seguro
          logger.i('Inicio de sesión exitoso');

          // Leer el token del almacenamiento seguro
          String? token = await _storage.read(key: 'token');
          if (token != null) {
            logger.i('Token almacenado: $token');
          } else {
            logger.e('No se encontró ningún token almacenado');
          }
        } else {
          logger.e('Respuesta inesperada: ${response.body}');
        }
      } else {
        logger.e('Error al iniciar sesión en Laravel: ${response.statusCode} - ${response.body}');
      }
    } catch (error) {
      logger.e('Error: $error');
    }
  }
}
