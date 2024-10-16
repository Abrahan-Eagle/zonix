import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:zonix/features/DomainProfiles/Profiles/models/profile_model.dart';
import 'package:zonix/features/DomainProfiles/Profiles/utils/constants.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class ProfileService {
  final _storage = const FlutterSecureStorage();

  // Obtiene el token almacenado.
  Future<String?> _getToken() async {
    return await _storage.read(key: 'token');
  }

  // Recupera un perfil por ID.
  Future<Profile?> getProfileById(int id) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$BASE_URL/profiles/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Profile.fromJson(data);
    } else {
      throw Exception('Error al obtener el perfil');
    }
  }

  // Recupera todos los perfiles.
  Future<List<Profile>> getAllProfiles() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$BASE_URL/profiles'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Profile.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener los perfiles');
    }
  }

  // Crea un nuevo perfil.
  Future<void> createProfile(Profile profile, {File? imageFile}) async {
    logger.i(profile);
    logger.i(imageFile);

    final token = await _getToken();
    final uri = Uri.parse('$BASE_URL/profiles');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['firstName'] = profile.firstName
      ..fields['lastName'] = profile.lastName
      ..fields['maritalStatus'] = profile.maritalStatus
      ..fields['sex'] = profile.sex
      ..fields['date_of_birth'] = profile.dateOfBirth;

    if (imageFile != null) {
      final image = await http.MultipartFile.fromPath('photo_users', imageFile.path);
      request.files.add(image);
    }

    logger.i(request);
    final response = await request.send();
    final responseData = await http.Response.fromStream(response);

    if (responseData.statusCode != 200) {
      throw Exception('Error al crear el perfil');
    }
  }

  // Actualiza un perfil existente.
  Future<void> updateProfile(int id, Profile profile, {File? imageFile}) async {
    final token = await _getToken();
    final uri = Uri.parse('$BASE_URL/profiles/$id');
    final request = http.MultipartRequest('PUT', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['firstName'] = profile.firstName
      ..fields['lastName'] = profile.lastName
      ..fields['maritalStatus'] = profile.maritalStatus
      ..fields['sex'] = profile.sex
      ..fields['date_of_birth'] = profile.dateOfBirth;

    if (imageFile != null) {
       logger.i('Imagen añadidaxxxxxxxxxxxxxxxxxxxxxxxxxxx: $imageFile');
      final image = await http.MultipartFile.fromPath('photo_users', imageFile.path);
       logger.i('Imagenimageimageimageimage añadidaxxxxxxxxxxxxxxxxxxxxxxxxxxx: $image');
      request.files.add(image);
       logger.i('requestrequestrequestrequestrequestrequestrequestrequest 1111111111111111111111111111111111: $request');
    }

    final response = await request.send();
     logger.i('ddddddddddddddddddddddddddddd 1111111111111111111111111111111111: $response');
    final responseData = await http.Response.fromStream(response);
     logger.i('responseDataresponseDataresponseDataresponseDataresponseDataresponseData: $responseData');

    if (responseData.statusCode != 200) {
      throw Exception('Error al actualizar el perfil');
    }
  }
}
