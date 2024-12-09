import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:zonix/features/GasTicket/sales_admin/data_verification/api/check_service.dart';  // Asegúrate de importar el archivo donde está ApiService

class CheckScannerScreen extends StatefulWidget {
  const CheckScannerScreen({super.key});

  @override
  CheckScannerScreenState createState() => CheckScannerScreenState();
}

class CheckScannerScreenState extends State<CheckScannerScreen> {
  late ApiService apiService;
  String scannedData = '';  // Para almacenar los datos escaneados
  Map<String, dynamic>? checkData;  // Datos del check escaneado

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

    // Verifica el check con el ID escaneado
    try {
      var result = await apiService.verifyCheck(int.parse(scannedData));
      setState(() {
        checkData = result['data'];  // Guardamos la data del check
      });
    } catch (e) {
      _showMessage('Error al verificar el check');
    }
  }

  // Función para mostrar un mensaje
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // Función para manejar la opción de pago (marcar como esperando)
  void _markAsWaiting() async {
    if (checkData != null) {
      try {
        var result = await apiService.markAsWaiting(checkData!['id']);
        _showMessage(result['message']);
        setState(() {
          checkData = null; // Limpiamos la información del check
        });
      } catch (e) {
        _showMessage('Error al marcar como esperando');
      }
    }
  }

  // Función para manejar la opción de cancelar el check
  void _cancelCheck() async {
    if (checkData != null) {
      try {
        var result = await apiService.cancelCheck(checkData!['id']);
        _showMessage(result['message']);
        setState(() {
          checkData = null; // Limpiamos la información del check
        });
      } catch (e) {
        _showMessage('Error al cancelar el check');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear Check'),
      ),
      body: Stack(
        children: [
          // Zona de escaneo de la cámara
          MobileScanner(
            onDetect: (BarcodeCapture barcodeCapture) {
              // Accediendo al primer código detectado
              if (barcodeCapture.barcodes.isNotEmpty) {
                final Barcode barcode = barcodeCapture.barcodes.first;
                _onScan(barcode);  // Llamamos a la función de escaneo con el código detectado
              }
            },
          ),

          // Zona de escaneo en el medio de la cámara
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 50.0), // Ajusta los márgenes para centrar el contenedor
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.green,
                  width: 2,
                ),
              ),
            ),
          ),

          // Capa de borde verde (opcional para visualización adicional)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green.withOpacity(0.7)),  // Aumenta la opacidad para una mejor visualización
              ),
            ),
          ),

          // Capa de la información del check (cuando se escanea un código válido)
          checkData != null
              ? Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('ID del check: ${checkData!['id']}'),
                        const SizedBox(height: 10),
                        Text('Usuario: ${checkData!['profile']['user']['name']}'),
                        const SizedBox(height: 10),
                        Text('Estado: ${checkData!['status']}'),
                        const SizedBox(height: 20),
                        Text('Fecha de Reserva: ${checkData!['reserved_date']}'),
                        const SizedBox(height: 10),
                        Text('Fecha de Cita: ${checkData!['appointment_date']}'),
                        const SizedBox(height: 10),
                        Text('Fecha de Expiración: ${checkData!['expiry_date']}'),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: _markAsWaiting,
                              child: const Text('Aprobar'),
                            ),
                            const SizedBox(width: 20),
                            ElevatedButton(
                              onPressed: _cancelCheck,
                              child: const Text('Cancelar'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}
