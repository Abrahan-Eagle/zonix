import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class AuthService {
  // Definir los alcances (scopes) para los permisos que se solicitarán al usuario
  static const List<String> scopes = <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ];

  // Configuración dinámica del clientId según la plataforma
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: scopes,
    clientId: kIsWeb
        ? '608143949661-420hekfq1bvmbpnn8oda1m9oopdooq2c.apps.googleusercontent.com' // Web Client ID
        : Platform.isAndroid
            ? '608143949661-6ef6sbfqu0vaahjndvdjoketva74r5r4.apps.googleusercontent.com' // Android Client ID
            : null, // Agrega más plataformas si es necesario
  );

  // Variable para manejar al usuario actualmente conectado
  GoogleSignInAccount? currentUser;

  // Stream para escuchar cambios en el estado del usuario actual
  Stream<GoogleSignInAccount?> get onCurrentUserChanged =>
      _googleSignIn.onCurrentUserChanged;

  // Intento de inicio de sesión silencioso
  Future<void> signInSilently() => _googleSignIn.signInSilently();

  // Manejar el inicio de sesión del usuario
  Future<void> handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print('Error en el inicio de sesión: $error');
    }
  }

  // Manejar el cierre de sesión del usuario
  Future<void> handleSignOut() => _googleSignIn.disconnect();

  // Obtener contactos del usuario utilizando Google People API
  Future<Map<String, dynamic>> getContact(GoogleSignInAccount user) async {
    final response = await http.get(
      Uri.parse(
          'https://people.googleapis.com/v1/people/me/connections?personFields=names,emailAddresses'),
      headers: await user.authHeaders,
    );

    if (response.statusCode != 200) {
      throw Exception('Fallo al cargar los contactos');
    }
    return json.decode(response.body) as Map<String, dynamic>;
  }
}
