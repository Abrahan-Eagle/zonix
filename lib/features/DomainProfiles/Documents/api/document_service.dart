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
      if (token == null) throw Exception('Token not found.');
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/documents/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        logger.i('Documents fetched successfully: ${jsonResponse.length} documents found.');
        return jsonResponse.map((doc) => Document.fromJson(doc)).toList();
      } else if (response.statusCode == 404) {
        logger.w('No documents found for profile ID: $id');
        return []; // Return an empty list if no documents are found
      } else {
        logger.e('Unexpected error: ${response.statusCode} - ${response.body}');
        throw Exception('Error fetching documents: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Error during fetchDocuments execution: $e');
      throw Exception('Error fetching documents: $e');
    }
  }

  Future<void> createDocument(
    Document document,
    int userId, {
    File? frontImageFile,
  }) async {
    logger.i('Creating document for profile ID: $userId');

    try {
      final token = await _getToken();
      if (token == null) throw Exception('Token not found.');

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/documents'),
      );

      // Configure headers and basic fields
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['profile_id'] = userId.toString();
      request.fields['type'] = document.type ?? '';
      request.fields['issued_at'] = document.issuedAt?.toIso8601String() ?? '';
      request.fields['expires_at'] = document.expiresAt?.toIso8601String() ?? '';

      // Configure additional fields based on type
      switch (document.type) {
        case 'ci':
          request.fields['number_ci'] = document.numberCi?.toString() ?? '';
          break;
        case 'passport':
          request.fields['number_ci'] = document.numberCi?.toString() ?? '';
          request.fields['RECEIPT_N'] = document.receiptN?.toString() ?? '';
          break;
        case 'rif':
          request.fields['sky'] = document.sky?.toString() ?? '';
          request.fields['RECEIPT_N'] = document.receiptN?.toString() ?? '';
          request.fields['rif_url'] = document.rifUrl ?? '';
          request.fields['taxDomicile'] = document.taxDomicile ?? '';
          break;
        case 'neighborhood_association':
          request.fields['commune_register'] = document.communeRegister ?? '';
          request.fields['community_rif'] = document.communityRif ?? '';
          break;
        default:
          logger.w('Unrecognized document type: ${document.type}');
      }

      // Attach images if available
      if (frontImageFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'front_image', frontImageFile.path,
        ));
      }

      // Send the request
      final response = await request.send();

      if (response.statusCode == 201) {
        logger.i('Document created successfully.');
      } else {
        final responseBody = await response.stream.bytesToString();
        logger.e('Error creating document: ${response.statusCode} - $responseBody');
        throw Exception('Error creating document: $responseBody');
      }
    } catch (e) {
      logger.e('Exception while creating document: $e');
      rethrow;
    }
  }
}


// import 'dart:convert';
// import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:logger/logger.dart';
// import '../models/document.dart';

// final logger = Logger();
// final String baseUrl = const bool.fromEnvironment('dart.vm.product')
//     ? dotenv.env['API_URL_PROD']!
//     : dotenv.env['API_URL_LOCAL']!;

// class DocumentService {
//   final _storage = const FlutterSecureStorage();

//   Future<String?> _getToken() async {
//     return await _storage.read(key: 'token');
//   }

//   Future<List<Document>> fetchDocuments(int id) async {
//     logger.i('Fetching documents for profile ID: $id');
//     final token = await _getToken();

//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/api/documents/$id'),
//         headers: {'Authorization': 'Bearer $token'},
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> jsonResponse = json.decode(response.body);
//         logger.i('Documents fetched successfully: ${jsonResponse.length} documents found.');
//         return jsonResponse.map((doc) => Document.fromJson(doc)).toList();
//       } else if (response.statusCode == 404) {
//         logger.w('No documents found for profile ID: $id');
//         return []; // Retorna una lista vacía si no se encuentran documentos
//       } else {
//         logger.e('Unexpected error: ${response.statusCode} - ${response.body}');
//         throw Exception('Error fetching documents: ${response.statusCode}');
//       }
//     } catch (e) {
//       logger.e('Error during fetchDocuments execution: $e');
//       throw Exception('Error fetching documents: $e');
//     }
//   }

//   Future<void> createDocument(
//     Document document,
//     int userId, {
//     File? frontImageFile,
//   }) async {
//     logger.i('Creating document for profile ID: $userId');

//     try {
//       final token = await _getToken();
//       if (token == null) throw Exception('Token no encontrado.');

//       final request = http.MultipartRequest(
//         'POST',
//         Uri.parse('$baseUrl/api/documents'),
//       );

//       // Configurar headers y campos base
//       request.headers['Authorization'] = 'Bearer $token';
//       request.fields['profile_id'] = userId.toString();
//       request.fields['type'] = document.type ?? '';
//       request.fields['issued_at'] = document.issuedAt?.toIso8601String() ?? '';
//       request.fields['expires_at'] = document.expiresAt?.toIso8601String() ?? '';

//       // Configurar campos adicionales según el tipo
//       switch (document.type) {
//         case 'ci':
//           request.fields['number_ci'] = document.numberCi?.toString() ?? '';
//           break;
//         case 'rif':
//           request.fields['sky'] = document.sky?.toString() ?? '';
//           request.fields['RECEIPT_N'] = document.receiptN?.toString() ?? '';
//           request.fields['rif_url'] = document.rifUrl ?? '';
//           request.fields['taxDomicile'] = document.taxDomicile ?? '';
//           break;
//         case 'neighborhood_association':
//           request.fields['commune_register'] = document.communeRegister ?? '';
//           request.fields['community_rif'] = document.communityRif ?? '';
//           break;
//         default:
//           logger.w('Tipo de documento no reconocido: ${document.type}');
//       }

//       // Adjuntar imágenes si están disponibles
//       if (frontImageFile != null) {
//         request.files.add(await http.MultipartFile.fromPath(
//           'front_image', frontImageFile.path,
//         ));
//       }

//       // Enviar la solicitud
//       final response = await request.send();

//       if (response.statusCode == 201) {
//         logger.i('Documento creado exitosamente.');
//       } else {
//         final responseBody = await response.stream.bytesToString();
//         logger.e('Error al crear documento: ${response.statusCode} - $responseBody');
//         throw Exception('Error al crear documento: $responseBody');
//       }
//     } catch (e) {
//       logger.e('Excepción al crear documento: $e');
//       rethrow;
//     }
//   }
// }




// // import 'dart:convert';
// // import 'dart:io';
// // import 'package:http/http.dart' as http;
// // import 'package:flutter_dotenv/flutter_dotenv.dart';
// // import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// // import 'package:logger/logger.dart';
// // import '../models/document.dart';

// // final logger = Logger();
// // final String baseUrl = const bool.fromEnvironment('dart.vm.product')
// //     ? dotenv.env['API_URL_PROD']!
// //     : dotenv.env['API_URL_LOCAL']!;

// // class DocumentService {
// //   final _storage = const FlutterSecureStorage();

// //   Future<String?> _getToken() async {
// //     return await _storage.read(key: 'token');
// //   }

// // Future<List<Document>> fetchDocuments(int id) async {
// //   logger.i('Fetching documents for profile ID: $id');
// //   final token = await _getToken();

// //   try {
// //     final response = await http.get(
// //       Uri.parse('$baseUrl/api/documents/$id'),
// //       headers: {'Authorization': 'Bearer $token'},
// //     );

// //     if (response.statusCode == 200) {
// //       final List<dynamic> jsonResponse = json.decode(response.body);
// //       logger.i('Documents fetched successfully: ${jsonResponse.length} documents found.');
// //       return jsonResponse
// //           .map((doc) => Document.fromJson(doc))
// //           .toList();
// //     } else if (response.statusCode == 404) {
// //       logger.w('No documents found for profile ID: $id');
// //       return []; // Retorna una lista vacía si no se encuentran documentos
// //     } else {
// //       logger.e('Unexpected error: ${response.statusCode} - ${response.body}');
// //       throw Exception('Error fetching documents: ${response.statusCode}');
// //     }
// //   } catch (e) {
// //     logger.e('Error during fetchDocuments execution: $e');
// //     throw Exception('Error fetching documents: $e');
// //   }
// // }

  
// // Future<void> createDocument(Document document, int userId, {
// //   File? frontImageFile,
  
// // }) async {
// //   logger.i('Creating document for profile ID: $userId');
// //   logger.i('receiptNreceiptNreceiptNreceiptNreceiptNreceiptNreceiptNreceiptNreceiptNreceiptNreceiptNreceiptNreceiptN: ${document.receiptN}');
// //   logger.i('taxDomiciletaxDomiciletaxDomiciletaxDomiciletaxDomiciletaxDomiciletaxDomiciletaxDomiciletaxDomiciletaxDomiciletaxDomicile: ${document.taxDomicile}');
// //   try {
// //     final token = await _getToken();
// //     if (token == null) throw Exception('Token no encontrado.');

// //     final request = http.MultipartRequest(
// //       'POST',
// //       Uri.parse('$baseUrl/api/documents'),
// //     );

// //     request.headers['Authorization'] = 'Bearer $token';
// //     request.fields['profile_id'] = userId.toString();
// //     request.fields['type'] = document.type ?? '';
// //     request.fields['number'] = document.number?.toString() ?? '';
// //     request.fields['RECEIPT_N'] = document.receiptN?.toString() ?? '';
// //     request.fields['rif_url'] = document.rifUrl ?? '';
// //     request.fields['taxDomicile'] = document.taxDomicile ?? '';
// //     request.fields['issued_at'] = document.issuedAt?.toIso8601String() ?? '';
// //     request.fields['expires_at'] = document.expiresAt?.toIso8601String() ?? '';

// //     // Adjuntar imágenes si están disponibles
// //     if (frontImageFile != null) {
// //       request.files.add(await http.MultipartFile.fromPath(
// //         'front_image', frontImageFile.path,
// //       ));
// //     }



// //     final response = await request.send();

// //     if (response.statusCode == 201) {
// //       logger.i('Documento creado exitosamente.');
// //     } else {
// //       final responseBody = await response.stream.bytesToString();
// //       logger.e('Error al crear documento: ${response.statusCode} - $responseBody');
// //       throw Exception('Error al crear documento: $responseBody');
// //     }
// //   } catch (e) {
// //     logger.e('Excepción al crear documento: $e');
// //     rethrow;
// //   }
// // }

// // }
