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

    final response = await http.get(
      Uri.parse('$baseUrl/api/documents/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse
          .map((doc) => Document.fromJson(doc))
          .toList();
    } else {
      logger.e('Error fetching documents: ${response.statusCode} - ${response.body}');
      throw Exception('Error fetching documents: ${response.statusCode}');
    }
  }

  
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

//     final response = await http.get(
//       Uri.parse('$baseUrl/api/documents/$id'),
//       headers: {'Authorization': 'Bearer $token'},
//     );

//     if (response.statusCode == 200) {
//       final List<dynamic> jsonResponse = json.decode(response.body);
//       return jsonResponse
//           .map((doc) => Document.fromJson(doc))
//           .toList();
//     } else {
//       logger.e('Error fetching documents: ${response.statusCode} - ${response.body}');
//       throw Exception('Error fetching documents: ${response.statusCode}');
//     }
//   }

//   Future<void> createDocument(Document document, int userId, {
//     File? frontImageFile,
//     File? backImageFile,
//   }) async {
//     logger.i('Creating document: type: ${document.type}, number: ${document.number}, receiptN: ${document.receiptN}, rifUrl: ${document.rifUrl}, taxDomicile: ${document.taxDomicile}, userId: $userId');
//     try {
//       final token = await _getToken();
//       if (token == null) throw Exception('Token no encontrado.');

//       final request = http.MultipartRequest(
//         'POST',
//         Uri.parse('$baseUrl/api/documents'),
//       );

//       request.headers['Authorization'] = 'Bearer $token';
//       request.fields['profile_id'] = userId.toString();
//       request.fields['type'] = document.type ?? '';
//       request.fields['number'] = document.number?.toString() ?? '';
//       request.fields['RECEIPT_N'] = document.receiptN?.toString() ?? '';
//       request.fields['rif_url'] = document.rifUrl ?? '';
//       request.fields['taxDomicile'] = document.taxDomicile ?? '';
//       request.fields['issued_at'] = document.issuedAt?.toIso8601String() ?? '';
//       request.fields['expires_at'] = document.expiresAt?.toIso8601String() ?? '';

//       // Asegúrate de que 'status' no sea nulo
//       request.fields['status'] = document.status?.toString() ?? 'false';

//       // Adjuntar imágenes si están disponibles
//       if (frontImageFile != null) {
//         request.files.add(await http.MultipartFile.fromPath(
//           'front_image', frontImageFile.path,
//         ));
//       }

//       if (backImageFile != null) {
//         request.files.add(await http.MultipartFile.fromPath(
//           'back_image', backImageFile.path,
//         ));
//       }

//       final response = await request.send();

//       // Manejar la respuesta
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

// //   Future<List<Document>> fetchDocuments(int id) async {
// //     logger.i('Fetching documents for profile ID: $id');
// //     final token = await _getToken();

// //     final response = await http.get(
// //       Uri.parse('$baseUrl/api/documents/$id'),
// //       headers: {'Authorization': 'Bearer $token'},
// //     );

// //     if (response.statusCode == 200) {
// //       final List<dynamic> jsonResponse = json.decode(response.body);
// //       return jsonResponse
// //           .map((doc) => Document.fromJson(doc))
// //           .toList();
// //     } else {
// //       logger.e('Error fetching documents: ${response.statusCode} - ${response.body}');
// //       throw Exception('Error fetching documents: ${response.statusCode}');
// //     }
// //   }

// //   Future<void> createDocument(Document document, int userId, { File? frontImageFile, File? backImageFile, }) async {

// //     logger.i('xxxxxxxxxxxxx111111122222223333333333333344444444Fetching documents for profile ID: $document.type, $document.number, $document.receiptN, $document.rifUrl, $document.taxDomicile, $userId');
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
    
// //     // Asumiendo que 'status' no es nulo
// //     request.fields['status'] = document.status.toString(); // Cambiado a solo 'document.status'

// //     // Adjuntar imágenes si están disponibles
// //     if (frontImageFile != null) {
// //       request.files.add(await http.MultipartFile.fromPath(
// //         'front_image', frontImageFile.path,
// //       ));
// //     }

// //     if (backImageFile != null) {
// //       request.files.add(await http.MultipartFile.fromPath(
// //         'back_image', backImageFile.path,
// //       ));
// //     }

// //     final response = await request.send();

// //     // Manejar la respuesta
// //     if (response.statusCode == 201) {
// //       logger.i('Documento creado exitosamente.');
// //     } else {
// //       final responseBody = await response.stream.bytesToString();
// //       final Map<String, dynamic> errorResponse = json.decode(responseBody);
// //       logger.e('Error al crear documento: ${response.statusCode} - ${errorResponse['error']}');
// //       throw Exception('Error al crear documento: ${errorResponse['error']}');
// //     }
// //   } catch (e) {
// //     logger.e('Excepción al crear documento: $e');
// //     rethrow;
// //   }
// // }

// // }








// // // import 'dart:convert';
// // // import 'dart:io';
// // // import 'package:http/http.dart' as http;
// // // import 'package:flutter_dotenv/flutter_dotenv.dart';
// // // import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// // // import 'package:logger/logger.dart';
// // // import '../models/document.dart';

// // // final logger = Logger();
// // // final String baseUrl = const bool.fromEnvironment('dart.vm.product')
// // //     ? dotenv.env['API_URL_PROD']!
// // //     : dotenv.env['API_URL_LOCAL']!;

// // // class DocumentService {
// // //   final _storage = const FlutterSecureStorage();

// // //   Future<String?> _getToken() async {
// // //     return await _storage.read(key: 'token');
// // //   }

// // //   Future<List<Document>> fetchDocuments(int id) async {
// // //     logger.i('Fetching documents for profile ID: $id');
// // //     final token = await _getToken();

// // //     final response = await http.get(
// // //       Uri.parse('$baseUrl/api/documents/$id'),
// // //       headers: {'Authorization': 'Bearer $token'},
// // //     );

// // //     if (response.statusCode == 200) {
// // //       final List<dynamic> jsonResponse = json.decode(response.body);
// // //       return jsonResponse
// // //           .map((doc) => Document.fromJson(doc))
// // //           .toList();
// // //     } else {
// // //       logger.e('Error fetching documents: ${response.statusCode} - ${response.body}');
// // //       throw Exception('Error fetching documents: ${response.statusCode}');
// // //     }
// // //   }

// // //   Future<void> createDocument(Document document, int userId,  {File? frontImageFile, File? backImageFile}) async {
// // //     try {
// // //       final token = await _getToken();
// // //       if (token == null) throw Exception('Token no encontrado.');

// // //       final request = http.MultipartRequest(
// // //         'POST',
// // //         Uri.parse('$baseUrl/api/documents'),
// // //       );

// // //       request.headers['Authorization'] = 'Bearer $token';
// // //       request.fields['user_id'] = userId.toString();
// // //       request.fields['type'] = document.type ?? '';
// // //       request.fields['number'] = document.number ?? '';
// // //       request.fields['receipt_n'] = document.receiptN?.toString() ?? '';
// // //       request.fields['rif_url'] = document.rifUrl ?? '';
// // //       request.fields['tax_domicile'] = document.taxDomicile ?? '';
// // //       request.fields['issued_at'] = document.issuedAt?.toIso8601String() ?? '';
// // //       request.fields['expires_at'] = document.expiresAt?.toIso8601String() ?? '';

// // //       // Adjuntar imágenes si están disponibles
// // //       if (frontImageFile != null) {
// // //         request.files.add(await http.MultipartFile.fromPath(
// // //           'front_image', frontImageFile.path,
// // //         ));
// // //       }

// // //       if (backImageFile != null) {
// // //         request.files.add(await http.MultipartFile.fromPath(
// // //           'back_image', backImageFile.path,
// // //         ));
// // //       }

// // //       final response = await request.send();
// // //       if (response.statusCode == 201) {
// // //         logger.i('Documento creado exitosamente.');
// // //       } else {
// // //         logger.e('Error al crear documento: ${response.statusCode}');
// // //         throw Exception('Error al crear documento');
// // //       }
// // //     } catch (e) {
// // //       logger.e('Excepción al crear documento: $e');
// // //       rethrow;
// // //     }
// // //   }
// // // }






// // // // import 'dart:convert';
// // // // import 'dart:io';
// // // // import 'package:http/http.dart' as http;
// // // // import 'package:zonix/features/DomainProfiles/Documents/models/document.dart';
// // // // import 'package:flutter_dotenv/flutter_dotenv.dart';
// // // // import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// // // // import 'package:logger/logger.dart';
// // // // final logger = Logger();
// // // // final String baseUrl = const bool.fromEnvironment('dart.vm.product')
// // // //     ? dotenv.env['API_URL_PROD']!
// // // //     : dotenv.env['API_URL_LOCAL']!;

// // // // class DocumentService {
// // // //   final _storage = const FlutterSecureStorage();

// // // //   Future<String?> _getToken() async {
// // // //     return await _storage.read(key: 'token');
// // // //   }

// // // //   Future<List<Document>> fetchDocuments(int id) async {
// // // //     logger.i('Fetching documents for profile ID: $id');
// // // //     final token = await _getToken();

// // // //     final response = await http.get(
// // // //       Uri.parse('$baseUrl/api/documents/$id'),
// // // //       headers: {'Authorization': 'Bearer $token'},
// // // //     );

// // // //     if (response.statusCode == 200) {
// // // //       final List<dynamic> jsonResponse = json.decode(response.body);
// // // //       return jsonResponse.map((doc) {
// // // //         try {
// // // //           return Document.fromJson(doc);
// // // //         } catch (e) {
// // // //           logger.e('Error parsing document: $e');
// // // //           return null;
// // // //         }
// // // //       }).whereType<Document>().toList(); // Filtrar nulos correctamente
// // // //     } else {
// // // //       logger.e('Error fetching documents: ${response.statusCode} - ${response.body}');
// // // //       throw Exception('Error fetching documents: ${response.statusCode}');
// // // //     }
// // // //   }


// // // //   Future<void> createDocument(Document document, int userId, {File? frontImageFile, File? backImageFile}) async {
// // // //   try {
// // // //     final token = await _getToken();
// // // //     if (token == null) throw Exception('Token no encontrado.');

// // // //     final request = http.MultipartRequest(
// // // //       'POST',
// // // //       Uri.parse('$baseUrl/api/documents'),
// // // //     );

// // // //     request.headers['Authorization'] = 'Bearer $token';
// // // //     request.fields['user_id'] = userId.toString();
// // // //     request.fields['type'] = document.type ?? ''; // Tipo del documento
// // // //     request.fields['count'] = document.count?.toString() ?? ''; // Contador del documento
// // // //     request.fields['number'] = document.number ?? ''; // Número del documento
// // // //     request.fields['RECEIPT_N'] = document.receiptN?.toString() ?? ''; // Número de recibo
// // // //     request.fields['rif_url'] = document.rifUrl ?? ''; // URL del RIF
// // // //     request.fields['taxDomicile'] = document.taxDomicile ?? ''; // Domicilio fiscal

// // // //     // Manejo de imágenes
// // // //     if (frontImageFile != null) {
// // // //       request.files.add(await http.MultipartFile.fromPath(
// // // //         'front_image', // Nombre del campo para la imagen frontal
// // // //         frontImageFile.path,
// // // //       ));
// // // //     }

// // // //     if (backImageFile != null) {
// // // //       request.files.add(await http.MultipartFile.fromPath(
// // // //         'back_image', // Nombre del campo para la imagen trasera
// // // //         backImageFile.path,
// // // //       ));
// // // //     }

// // // //     // Manejo de fechas (convertir a string ISO 8601 si es necesario)
// // // //     if (document.issuedAt != null) {
// // // //       request.fields['issued_at'] = document.issuedAt!.toIso8601String();
// // // //     }

// // // //     if (document.expiresAt != null) {
// // // //       request.fields['expires_at'] = document.expiresAt!.toIso8601String();
// // // //     }

// // // //     final response = await request.send();

// // // //     if (response.statusCode == 201) {
// // // //       logger.i('Documento creado exitosamente.');
// // // //     } else {
// // // //       final responseBody = await response.stream.bytesToString();
// // // //       logger.e('Error al crear el documento: $responseBody');
// // // //       throw Exception('Error al crear el documento: ${response.statusCode} - $responseBody');
// // // //     }
// // // //   } catch (e) {
// // // //     logger.e('createDocument error: $e');
// // // //     rethrow;
// // // //   }
// // // // }

// // // // }
