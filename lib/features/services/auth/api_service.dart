// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:logger/logger.dart';

// final logger = Logger();

// class ApiService {
//   final FlutterSecureStorage _storage = const FlutterSecureStorage();

//   // Verificar si el usuario está autenticado al abrir la app
//   Future<bool> isLoggedIn() async {
//     String? token = await _storage.read(key: 'token');
//     if (token != null) {
//       // Opcional: podrías verificar si el token aún es válido llamando a un endpoint
//       return true;
//     }
//     return false;
//   }

//   // Obtener el rol del usuario almacenado
//   Future<String?> getUserRole() async {
//     return await _storage.read(key: 'role');
//   }

//   // Función de login: almacena token y rol del usuario
//   Future<void> sendTokenToBackend(String? result) async {
//     if (result == null) {
//       logger.e('Error: el data es null');
//       return;
//     }

//     final decodedData = jsonDecode(result); // Decodificar el JSON

//     try {
//       final body = jsonEncode({
//         'success': true,
//         'token': decodedData['token'],
//         'data': decodedData['profile'],
//         'message': 'Datos recibidos correctamente.',
//       });

//       final response = await http.post(
//         Uri.parse('http://127.0.0.1:8000/api/auth/google'), // Cambia por la URL de tu backend
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//           'User-Agent': 'flutter/1.0',
//         },
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
//         var $varToken = responseData['token'];
//         logger.i($varToken);

//         // Verificación más flexible para el token
//         if ($varToken != null) {
//           await _storage.write(key: 'token', value: responseData['token']);  // Guardar el JWT
//           await _storage.write(key: 'role', value: responseData['profile']['role']);  // Guardar el rol del usuario
//           logger.i('Inicio de sesión exitoso');

//           // Leer el token y el rol del almacenamiento seguro
//           String? token = await _storage.read(key: 'token');
//           String? role = await _storage.read(key: 'role');
//           if (token != null && role != null) {
//             logger.i('Token almacenado: $token');
//             logger.i('Rol almacenado: $role');
//           } else {
//             logger.e('No se encontró el token o el rol almacenado');
//           }
//         } else {
//           logger.e('Respuesta inesperada: ${response.body}');
//         }
//       } else {
//         logger.e('Error al iniciar sesión en Laravel: ${response.statusCode} - ${response.body}');
//       }
//     } catch (error) {
//       logger.e('Error: $error');
//     }
//   }

//   // Cerrar sesión
//   Future<void> logout() async {
//     String? token = await _storage.read(key: 'token');
//     if (token != null) {
//       final response = await http.post(
//         Uri.parse('http://127.0.0.1:8000/api/auth/logout'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json'
//         },
//       );
//       if (response.statusCode == 200) {
//         await _storage.delete(key: 'token');
//         await _storage.delete(key: 'role');
//         logger.i("Sesión cerrada correctamente");
//       } else {
//         logger.e("Error al cerrar sesión: ${response.body}");
//       }
//     } else {
//       logger.e("No hay token almacenado para cerrar sesión");
//     }
//   }

//   // Enviar una solicitud autenticada
//   Future<void> sendAuthenticatedRequest() async {
//     String? token = await _storage.read(key: 'token');
//     if (token != null) {
//       final response = await http.get(
//         Uri.parse('http://127.0.0.1:8000/api/auth/protected-endpoint'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Accept': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         logger.i("Datos recibidos: ${response.body}");
//       } else if (response.statusCode == 401) {
//         logger.e("Token expirado o inválido, redirigiendo a login");
//         // Redirige al login
//       } else {
//         logger.e("Error al realizar solicitud: ${response.body}");
//       }
//     } else {
//       logger.e("No hay token almacenado para la solicitud");
//     }
//   }
// }



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


Future<http.Response> logout(String token) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/api/auth/logout'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    return response;
  }

  // Future<void> logout() async {
  //   String? token = await _storage.read(key: 'token');
  //   if (token != null) {
  //     final response = await http.post(
  //       Uri.parse('http://127.0.0.1:8000/api/auth/logout'),
  //       headers: {
  //         'Authorization': 'Bearer $token',
  //         'Content-Type': 'application/json'
  //       },
  //     );
  //     if (response.statusCode == 200) {
  //       await _storage.delete(key: 'token');
  //       logger.i("Sesión cerrada correctamente");
  //     } else {
  //       logger.e("Error al cerrar sesión: ${response.body}");
  //     }
  //   }
  // }

  Future<void> sendAuthenticatedRequest() async {
    String? token = await _storage.read(key: 'token');
    if (token != null) {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/protected-endpoint'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        logger.i("Datos recibidos: ${response.body}");
      } else if (response.statusCode == 401) {
        logger.e("Token expirado o inválido, redirigiendo a login");
        // Redirige al login
      }
    } else {
      logger.e("No hay token almacenado");
    }
  }
}
