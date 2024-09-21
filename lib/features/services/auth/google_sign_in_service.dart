import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:logger/logger.dart';

final logger = Logger();

class GoogleSignInService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/userinfo.profile',
      'https://www.googleapis.com/auth/userinfo.email',
    ],
    // clientId: '608143949661-420hekfq1bvmbpnn8oda1m9oopdooq2c.apps.googleusercontent.com',

     clientId: kIsWeb
        ? '608143949661-420hekfq1bvmbpnn8oda1m9oopdooq2c.apps.googleusercontent.com' // Web Client ID
        : Platform.isAndroid
            ? '608143949661-6ef6sbfqu0vaahjndvdjoketva74r5r4.apps.googleusercontent.com' // Android Client ID
            : null, // Agrega más plataformas si es necesario

  );

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      final user = await _googleSignIn.signIn();
      if (user == null) {
        logger.i('Inicio de sesión cancelado');
        return null;
      }

      final googleAuth = await user.authentication;

      // Obtener datos del perfil del usuario
      final profileResponse = await http.get(
        Uri.parse('https://www.googleapis.com/oauth2/v3/userinfo'),
        headers: {
          'Authorization': 'Bearer ${googleAuth.accessToken}',
        },
      );

      if (profileResponse.statusCode == 200) {
        final profileData = jsonDecode(profileResponse.body);
        logger.i('Datos del perfil de usuario: ${jsonEncode(profileData)}');
        return {
          'token': googleAuth.idToken,
          'profile': profileData,
        };
      } else {
        logger.i('Error al obtener los datos del perfil');
        return null;
      }
    } catch (error) {
      logger.i('Error: $error');
      return null;
    }
  }
}
