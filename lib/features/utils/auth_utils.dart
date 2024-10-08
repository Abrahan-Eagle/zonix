import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:zonix/features/services/auth/api_service.dart';

const FlutterSecureStorage _storage = FlutterSecureStorage();
final ApiService _apiService = ApiService();

class AuthUtils {
  // Método para verificar si el usuario está autenticado
  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    final expiryDateStr = await getExpiryDate();

    if (token != null && expiryDateStr != null) {
      final expiryDate = DateTime.parse(expiryDateStr);
      if (DateTime.now().isBefore(expiryDate)) {
        return true; // El token es válido
      } else {
        await _storage.deleteAll(); // Eliminar token si ha expirado
      }
    }
    return false; // No hay token o ha expirado
  }

  // Método para guardar el token y la fecha de expiración
  static Future<void> saveToken(String token, int expiresIn) async {
    await _storage.write(key: 'token', value: token);
    final expiryDate = DateTime.now().add(Duration(seconds: expiresIn));
    await _storage.write(key: 'expiryDate', value: expiryDate.toIso8601String());
  }

  // Método para obtener el token
  static Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  // Método para obtener la fecha de expiración
  static Future<String?> getExpiryDate() async {
    return await _storage.read(key: 'expiryDate');
  }

  // Método para eliminar todos los tokens
  static Future<void> clearTokens() async {
    await _storage.deleteAll();
  }

  // Maneja el cierre de sesión
  static Future<void> logout() async {
    try {
      final token = await _storage.read(key: 'token');
      if (token != null) {
        final response = await _apiService.logout(token);
        if (response.statusCode == 200) {
          await _storage.deleteAll();
          logger.i('Sesión cerrada correctamente');
        } else {
          logger.e('Error: ${response.statusCode}');
          throw Exception('Error en la API al cerrar sesión');
        }
      }
    } catch (e) {
      logger.e('Error al cerrar sesión: $e');
    }
  }

  // Métodos para guardar datos del usuario (nombre, correo, foto)
  static Future<void> saveUserName(String userName) async {
    await _storage.write(key: 'userName', value: userName);
  }

  static Future<void> saveUserEmail(String userEmail) async {
    await _storage.write(key: 'userEmail', value: userEmail);
  }

  static Future<void> saveUserPhotoUrl(String photoUrl) async {
    await _storage.write(key: 'userPhotoUrl', value: photoUrl);
  }

  // Métodos para obtener los datos del usuario
  static Future<String?> getUserName() async {
    return await _storage.read(key: 'userName');
  }

  static Future<String?> getUserEmail() async {
    return await _storage.read(key: 'userEmail');
  }

  // static Future<String?> getUserPhotoUrl() async {
  //   return await _storage.read(key: 'userPhotoUrl');
  // }

  static Future<String?> getUserPhotoUrl() async {
  return await _storage.read(key: 'userPhotoUrl');
}
}



// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:zonix/features/services/auth/api_service.dart';

// const FlutterSecureStorage _storage =  FlutterSecureStorage();
// final ApiService _apiService = ApiService();

// class AuthUtils {
//   // static const FlutterSecureStorage _storage = FlutterSecureStorage();
//   // static final ApiService _apiService = ApiService();

//   // Método para verificar si el usuario está autenticado
//   static Future<bool> isAuthenticated() async {
//     final token = await getToken();
//     final expiryDateStr = await getExpiryDate();

//     if (token != null && expiryDateStr != null) {
//       final expiryDate = DateTime.parse(expiryDateStr);
//       if (DateTime.now().isBefore(expiryDate)) {
//         return true; // El token es válido
//       } else {
//         await _storage.deleteAll(); // Eliminar token si ha expirado
//       }
//     }
//     return false; // No hay token o ha expirado
//   }

//   // Método para guardar el token y la fecha de expiración
//   static Future<void> saveToken(String token, int expiresIn) async {
//     await _storage.write(key: 'token', value: token);
//     final expiryDate = DateTime.now().add(Duration(seconds: expiresIn));
//     await _storage.write(key: 'expiryDate', value: expiryDate.toIso8601String());
//   }

//   // Método para obtener el token
//   static Future<String?> getToken() async {
//     return await _storage.read(key: 'token');
//   }

//   // Método para obtener la fecha de expiración
//   static Future<String?> getExpiryDate() async {
//     return await _storage.read(key: 'expiryDate');
//   }

//   // Método para eliminar todos los tokens
//   static Future<void> clearTokens() async {
//     await _storage.deleteAll();
//   }

//   // Maneja el cierre de sesión
//   static Future<void> logout() async {
//     try {
//       final token = await _storage.read(key: 'token');
//       if (token != null) {
//         final response = await _apiService.logout(token);
//         if (response.statusCode == 200) {
//           await _storage.deleteAll();
//           logger.i('Sesión cerrada correctamente');
//         } else {
//           logger.e('Error: ${response.statusCode}');
//           throw Exception('Error en la API al cerrar sesión');
//         }
//       }
//     } catch (e) {
//       logger.e('Error al cerrar sesión: $e');
//     }
//   }
// }


// class AuthUtils {

//   // Método para verificar si el usuario está autenticado
//   static Future<bool> isAuthenticated() async {
//     final token = await getToken();
//     final expiryDateStr = await getExpiryDate();

//     if (token != null && expiryDateStr != null) {
//       final expiryDate = DateTime.parse(expiryDateStr);
//       if (DateTime.now().isBefore(expiryDate)) {
//         return true; // El token es válido
//       } else {
//         await _storage.deleteAll(); // Eliminar token si ha expirado
//       }
//     }
//     return false; // No hay token
//   }

//   // Método para guardar el token y la fecha de expiración
//   static Future<void> saveToken(String token, int expiresIn) async {
//     await _storage.write(key: 'token', value: token);
//     final expiryDate = DateTime.now().add(Duration(seconds: expiresIn));
//     await _storage.write(key: 'expiryDate', value: expiryDate.toIso8601String());
//   }

//   // Método para obtener el token
//   static Future<String?> getToken() async {
//     return await _storage.read(key: 'token');
//   }

//   // Método para obtener la fecha de expiración
//   static Future<String?> getExpiryDate() async {
//     return await _storage.read(key: 'expiryDate');
//   }

//   // Método para eliminar todos los tokens
//   static Future<void> clearTokens() async {
//     await _storage.deleteAll();
//   }

//   // Maneja el cierre de sesión
//   static Future<void> logout() async {
//     try {
//       final token = await _storage.read(key: 'token');
//       if (token != null) {
//         final response = await _apiService.logout(token);
//         if (response.statusCode == 200) {
//           await _storage.deleteAll();
//           logger.i('Sesión cerrada correctamente');
//         } else {
//           logger.e('Error: ${response.statusCode}');
//           throw Exception('Error en la API al cerrar sesión');
//         }
//       }
//     } catch (e) {
//       logger.e('Error al cerrar sesión: $e');
//     }
//   }


// }
