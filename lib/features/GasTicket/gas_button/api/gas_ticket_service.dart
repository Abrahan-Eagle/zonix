import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:zonix/features/GasTicket/gas_button/models/gas_ticket.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
final String baseUrl = const bool.fromEnvironment('dart.vm.product')
      ? dotenv.env['API_URL_PROD']!
      : dotenv.env['API_URL_LOCAL']!;
class GasTicketService {
  final String apiUrl = '$baseUrl/api/tickets';
  final storage = const FlutterSecureStorage(); // Instancia de almacenamiento seguro

  // Método para recuperar el token almacenado
  Future<String?> _getToken() async {
    return await storage.read(key: 'token');
  }

  // Obtener la lista de tickets con autenticación
  // Future<List<GasTicket>> fetchGasTickets() async {
  //   String? token = await _getToken();

  //   if (token == null) {
  //     throw Exception('Token no encontrado. Por favor, inicia sesión.');
  //   }

  //   final response = await http.get(
  //     Uri.parse(apiUrl),
  //     headers: {
  //       'Content-Type': 'application/json',
  //       'Authorization': 'Bearer $token', // Envío del token
  //     },
  //   );

  //   if (response.statusCode == 200) {
  //     List<dynamic> data = jsonDecode(response.body);
  //     return data.map((json) => GasTicket.fromJson(json)).toList();
  //   } else {
  //     throw Exception('Error al cargar los tickets: ${response.body}');
  //   }
  // }


 // Obtener los tickets de un usuario por ID
  // Future<List<GasTicket>> fetchGasTickets(int userId) async {
  //   String? token = await _getToken();

  //   if (token == null) {
  //     throw Exception('Token no encontrado. Por favor, inicia sesión.');
  //   }

  //   final response = await http.get(
  //     Uri.parse('$apiUrl/$userId'), // Endpoint ajustado con {id}
  //     headers: {
  //       'Content-Type': 'application/json',
  //       'Authorization': 'Bearer $token',
  //     },
  //   );

  //   if (response.statusCode == 200) {
  //     List<dynamic> data = jsonDecode(response.body);
  //     return data.map((json) => GasTicket.fromJson(json)).toList();
  //   } else {
  //     throw Exception('Error al cargar los tickets: ${response.body}');
  //   }
  // }

// Modificación en GasTicketService
Future<List<GasTicket>> fetchGasTickets(int userId) async {
  String? token = await _getToken();

  if (token == null) {
    throw Exception('Token no encontrado. Por favor, inicia sesión.');
  }

  final response = await http.get(
    Uri.parse('$apiUrl/$userId'), // Asegúrate de que la URL sea correcta
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(response.body);
    // Manejar caso donde no hay tickets
    return data.isNotEmpty ? data.map((json) => GasTicket.fromJson(json)).toList() : [];
  } else {
    throw Exception('Error al cargar los tickets: ${response.body}');
  }
}

 Future<List<Map<String, dynamic>>> fetchGasCylinders(int userId) async {
   String? token = await _getToken();
   
    final response = await http.get(
      Uri.parse('$apiUrl/getGasCylinders/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => e as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load gas cylinders');
    }
  }

  // Crear un nuevo ticket con autenticación
  Future<void> createGasTicket(int profileId, int cylinderId) async {
    String? token = await _getToken();

    if (token == null) {
      throw Exception('Token no encontrado. Por favor, inicia sesión.');
    }

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Envío del token
      },
      body: jsonEncode({
        'profile_id': profileId,
        'gas_cylinders_id': cylinderId,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception(
          'Error al crear el ticket: ${response.statusCode} - ${response.body}');
    }
  }
}