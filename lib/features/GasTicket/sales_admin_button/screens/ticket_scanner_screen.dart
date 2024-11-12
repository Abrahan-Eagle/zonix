import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:zonix/features/GasTicket/sales_admin_button/api/sales_admin_service.dart';  // Asegúrate de importar el archivo donde está ApiService

class TicketScannerScreen extends StatefulWidget {
  const TicketScannerScreen({super.key});

  @override
  TicketScannerScreenState createState() => TicketScannerScreenState();
}

class TicketScannerScreenState extends State<TicketScannerScreen> {
  late ApiService apiService;
  String scannedData = '';  // Para almacenar los datos escaneados
  Map<String, dynamic>? ticketData;  // Datos del ticket escaneado

  @override
  void initState() {
    super.initState();
    apiService = ApiService();  // Inicializa la instancia de ApiService
  }

  // Función que se llama cuando se escanea un código QR
  void _onScan(Barcode barcode) async {
    setState(() {
      scannedData = barcode.rawValue ?? 'Unknown';  // Accediendo al rawValue del Barcode
    });

    // Verifica el ticket con el ID escaneado
    try {
      var result = await apiService.verifyTicket(int.parse(scannedData));
      setState(() {
        ticketData = result['data'];  // Guardamos la data del ticket
      });
    } catch (e) {
      _showMessage('Error al verificar el ticket');
    }
  }

  // Función para mostrar un mensaje
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // Función para manejar la opción de pago (marcar como esperando)
  void _markAsWaiting() async {
    if (ticketData != null) {
      try {
        var result = await apiService.markAsWaiting(ticketData!['id']);
        _showMessage(result['message']);
        setState(() {
          ticketData = null; // Limpiamos la información del ticket
        });
      } catch (e) {
        _showMessage('Error al marcar como esperando');
      }
    }
  }

  // Función para manejar la opción de cancelar el ticket
  void _cancelTicket() async {
    if (ticketData != null) {
      try {
        var result = await apiService.cancelTicket(ticketData!['id']);
        _showMessage(result['message']);
        setState(() {
          ticketData = null; // Limpiamos la información del ticket
        });
      } catch (e) {
        _showMessage('Error al cancelar el ticket');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear Ticket'),
      ),
      body: ticketData == null
          ? MobileScanner(
              onDetect: (BarcodeCapture barcodeCapture) {
                // Accediendo al primer código detectado
                if (barcodeCapture.barcodes.isNotEmpty) {
                  final Barcode barcode = barcodeCapture.barcodes.first;
                  _onScan(barcode);  // Llamamos a la función de escaneo con el código detectado
                }
              },
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ID del ticket: ${ticketData!['id']}'),
                  const SizedBox(height: 10),
                  Text('Usuario: ${ticketData!['profile']['user']['name']}'),
                  const SizedBox(height: 10),
                  Text('Estado: ${ticketData!['status']}'),
                  const SizedBox(height: 20),
                  Text('Fecha de Reserva: ${ticketData!['reserved_date']}'),
                  const SizedBox(height: 10),
                  Text('Fecha de Cita: ${ticketData!['appointment_date']}'),
                  const SizedBox(height: 10),
                  Text('Fecha de Expiración: ${ticketData!['expiry_date']}'),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _markAsWaiting,
                        child: const Text('Pagar'),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: _cancelTicket,
                        child: const Text('Cancelar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
