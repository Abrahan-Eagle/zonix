import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:zonix/features/utils/auth_utils.dart';
import 'package:logger/logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

final logger = Logger();
const FlutterSecureStorage _storage = FlutterSecureStorage();

final String baseUrl = const bool.fromEnvironment('dart.vm.product')
    ? dotenv.env['API_URL_PROD']!
    : dotenv.env['API_URL_LOCAL']!;

class UserProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String _userName = '';
  String _userEmail = '';
  String _userPhotoUrl = '';
  int _userId = 0; // Nuevo campo para el ID del usuario

  // Getters para obtener la información del usuario
  bool get isAuthenticated => _isAuthenticated;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userPhotoUrl => _userPhotoUrl;
  int get userId => _userId; // Getter para el ID del usuario

  // Verifica si el usuario está autenticado y carga los datos si es necesario
  Future<void> checkAuthentication() async {
  try {
    _isAuthenticated = await AuthUtils.isAuthenticated();
    if (_isAuthenticated) {
      await getUserDetails(); // Actualiza los datos desde la API
      await _loadUserData(); // Carga cualquier dato adicional desde almacenamiento seguro
      logger.i('Final userId: $_userId');
    }
  } catch (e) {
    debugPrint('Error al verificar autenticación: $e');
  } finally {
    notifyListeners();
  }
}


  // Carga la información del usuario desde el almacenamiento seguro
  Future<void> _loadUserData() async {
    try {
      _userName = await AuthUtils.getUserName() ?? '';
      _userEmail = await AuthUtils.getUserEmail() ?? '';
      _userPhotoUrl = await AuthUtils.getUserPhotoUrl() ?? '';
      _userId = await AuthUtils.getUserId() ?? 0; // Carga el ID del usuario
    } catch (e) {
      debugPrint('Error al cargar datos del usuario: $e');
    }
  }

  Future<Map<String, dynamic>> getUserDetails() async {
    try {
      final token = await _storage.read(key: 'token');
      if (token == null) {
        throw Exception('Token no encontrado. El usuario no está autenticado.');
      }

      logger.i('Retrieved token: $token');
      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/user'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final userDetails = jsonDecode(response.body);
        _userId = userDetails['id']; // Asigna el ID del usuario
        final role = await _storage.read(key: 'role') ?? 'guest';
        logger.i('User details: $userDetails');
        logger.i('User role: $role');
        logger.i('User _userId_userId_userId_userId_userId_userId_userId_userIdxxx1122233: $_userId');
        return {'users': userDetails, 'role': role, 'userId':_userId};
      } else {
        logger.e('Error: ${response.statusCode} - ${response.body}');
        throw Exception('Error al obtener detalles del usuario');
      }
    } catch (e) {
      logger.e('Exception: $e');
      rethrow;
    }
  }

  // Guarda los datos del usuario autenticado y actualiza el estado
  Future<void> setUserData(GoogleSignInAccount googleUser) async {
    try {
      _updateUserInfo(
        name: googleUser.displayName ?? '',
        email: googleUser.email,
        photoUrl: googleUser.photoUrl ?? '',
      );

      await AuthUtils.saveUserName(_userName);
      await AuthUtils.saveUserEmail(_userEmail);
      await AuthUtils.saveUserPhotoUrl(_userPhotoUrl);
      await AuthUtils.saveUserId(_userId); // Guarda el ID del usuario

      _isAuthenticated = true;
    } catch (e) {
      debugPrint('Error al guardar datos del usuario: $e');
    } finally {
      notifyListeners();
    }
  }

  // Actualiza la información del usuario en memoria
  void _updateUserInfo({required String name, required String email, required String photoUrl}) {
    _userName = name;
    _userEmail = email;
    _userPhotoUrl = photoUrl;
  }

  // Cierra la sesión, limpia los datos y actualiza el estado
  Future<void> logout() async {
    try {
      await AuthUtils.logout();
      _clearUserData();
    } catch (e) {
      debugPrint('Error al cerrar sesión: $e');
    } finally {
      notifyListeners();
    }
  }

  // Limpia la información del usuario
  void _clearUserData() {
    _isAuthenticated = false;
    _userName = '';
    _userEmail = '';
    _userPhotoUrl = '';
    _userId = 0; // Resetea el ID del usuario
  }
}
