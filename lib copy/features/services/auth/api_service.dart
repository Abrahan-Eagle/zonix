import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Importa FlutterSecureStorage

final logger = Logger();
const FlutterSecureStorage _storage = FlutterSecureStorage(); // Inicializa _storage

class ApiService {

 Future<http.Response> sendTokenToBackend(String? result) async {
    if (result == null) {
      logger.e('Error: el data es null');
      throw Exception('El data es null'); // Lanza una excepción
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
        Uri.parse('http://192.168.0.102:8000/api/auth/google'), // Cambia por la URL de tu backend
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'flutter/1.0',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        logger.i('Respuesta del servidor: $responseData');
        var $varToken = responseData['token'];
        logger.i($varToken);

        // Verificación más flexible para data
        if ($varToken != null) {
          await _storage.write(key: 'token', value: responseData['token']);  // Guardar el JWT en almacenamiento seguro
         await _storage.write(key: 'role', value: responseData['role']);
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
        logger.e('Error: ${response.statusCode}');
      }

      return response; // Devuelve la respuesta
    } catch (error) {
      logger.e('Error: $error');
      throw Exception('Error en el envío de datos: $error'); // Lanza una excepción
    }
  }



  Future<http.Response> logout(String token) async {
    final response = await http.post(
      Uri.parse('http://192.168.0.102:8000/api/auth/logout'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    return response;
  }

  Future<void> sendAuthenticatedRequest() async {
    final token = await _storage.read(key: 'token');
    if (token != null) {
      final response = await http.get(
        Uri.parse('http://192.168.0.102:8000/api/auth/protected-endpoint'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        logger.i("Datos recibidos: ${response.body}");
      } else if (response.statusCode == 401) {
        logger.e("Token expirado o inválido, redirigiendo a login");
        // Elimina el token almacenado y redirige al login
        await _storage.deleteAll();
        // Aquí puedes redirigir automáticamente al login
      } else {
        logger.e("Error en la solicitud: ${response.statusCode}");
      }
    } else {
      logger.e("No hay token almacenado");
    }
  }
}