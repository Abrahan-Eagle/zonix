import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import '../models/document.dart';

final logger = Logger();
final String baseUrl = const bool.fromEnvironment('dart.vm.product')
    ? dotenv.env['API_URL_PROD']!
    : dotenv.env['API_URL_LOCAL']!;

class DocumentService {
  final _storage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _storage.read(key: 'token');
  }

Future<List<Document>> fetchDocuments(int id) async {
  logger.i('Fetching documents for profile ID: $id');
  final token = await _getToken();

  try {
    final response = await http.get(
      Uri.parse('$baseUrl/api/documents/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      logger.i('Documents fetched successfully: ${jsonResponse.length} documents found.');
      return jsonResponse
          .map((doc) => Document.fromJson(doc))
          .toList();
    } else if (response.statusCode == 404) {
      logger.w('No documents found for profile ID: $id');
      return []; // Retorna una lista vacía si no se encuentran documentos
    } else {
      logger.e('Unexpected error: ${response.statusCode} - ${response.body}');
      throw Exception('Error fetching documents: ${response.statusCode}');
    }
  } catch (e) {
    logger.e('Error during fetchDocuments execution: $e');
    throw Exception('Error fetching documents: $e');
  }
}



  // Future<List<Document>> fetchDocuments(int id) async {
  //   logger.i('Fetching documents for profile ID: $id');
  //   final token = await _getToken();

  //   final response = await http.get(
  //     Uri.parse('$baseUrl/api/documents/$id'),
  //     headers: {'Authorization': 'Bearer $token'},
  //   );

  //   if (response.statusCode == 200) {
  //     final List<dynamic> jsonResponse = json.decode(response.body);
  //     return jsonResponse
  //         .map((doc) => Document.fromJson(doc))
  //         .toList();
  //   } else {
  //     logger.e('Error fetching documents: ${response.statusCode} - ${response.body}');
  //     throw Exception('Error fetching documents: ${response.statusCode}');
  //   }
  // }

  
Future<void> createDocument(Document document, int userId, {
  File? frontImageFile,
  File? backImageFile,
}) async {
  logger.i('Creating document for profile ID: $userId');
  try {
    final token = await _getToken();
    if (token == null) throw Exception('Token no encontrado.');

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/documents'),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.fields['profile_id'] = userId.toString();
    request.fields['type'] = document.type ?? '';
    request.fields['number'] = document.number?.toString() ?? '';
    request.fields['RECEIPT_N'] = document.receiptN?.toString() ?? '';
    request.fields['rif_url'] = document.rifUrl ?? '';
    request.fields['taxDomicile'] = document.taxDomicile ?? '';
    request.fields['issued_at'] = document.issuedAt?.toIso8601String() ?? '';
    request.fields['expires_at'] = document.expiresAt?.toIso8601String() ?? '';

    // Adjuntar imágenes si están disponibles
    if (frontImageFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'front_image', frontImageFile.path,
      ));
    }

    if (backImageFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'back_image', backImageFile.path,
      ));
    }

    final response = await request.send();

    if (response.statusCode == 201) {
      logger.i('Documento creado exitosamente.');
    } else {
      final responseBody = await response.stream.bytesToString();
      logger.e('Error al crear documento: ${response.statusCode} - $responseBody');
      throw Exception('Error al crear documento: $responseBody');
    }
  } catch (e) {
    logger.e('Excepción al crear documento: $e');
    rethrow;
  }
}

}
