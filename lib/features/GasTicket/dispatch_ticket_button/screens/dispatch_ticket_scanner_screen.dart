import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:zonix/features/GasTicket/dispatch_ticket_button/api/dispatch_ticket_service.dart';

class DispatcherScreen extends StatefulWidget {
  const DispatcherScreen({super.key});

  @override
  DispatcherScreenState createState() => DispatcherScreenState();
}

class DispatcherScreenState extends State<DispatcherScreen> {
  late ApiService apiService;
  String scannedData = '';
  Map<String, dynamic>? cylinderData;
  int? ticketId; // Cambia a tipo int
  bool isLoading = false;
  bool isUserScan = false; // Flag to indicate user QR scan

  @override
  void initState() {
    super.initState();
    apiService = ApiService();
  }

  // Función para reiniciar la pantalla a su estado inicial
  void resetScreen() {
    setState(() {
      scannedData = '';
      cylinderData = null;
      ticketId = null;
      isLoading = false;
      isUserScan = false;
    });
  }

  Future<void> _handleScan(Barcode barcode, {bool isCylinderScan = true}) async {
    setState(() {
      scannedData = barcode.rawValue?.trim() ?? 'Unknown';
      isLoading = true;
    });

    try {
      if (isCylinderScan) {
        var result = await apiService.scanCylinder(scannedData);

        setState(() {
          cylinderData = (result['data'] is List && result['data'].isNotEmpty)
              ? result['data'][0]
              : result['data'];
          ticketId = cylinderData?['id']; // Asignamos ticketId desde cylinderData
          logger.i('Escaneo de bombona - ticketId: $ticketId');
        });
      } else {
        _showMessage('Código escaneado no es válido para un ticket');
      }
    } catch (e) {
      _showMessage('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // Handle the User QR scan
  Future<void> _handleUserScan(Barcode barcode) async {
    setState(() {
      isLoading = true;
    });

    try {
      var scannedId = int.tryParse(barcode.rawValue?.trim() ?? '');
      logger.i('Ticket ID: $ticketId, Escaneado: $scannedId');
    
      if (ticketId != null && scannedId != null) {
        if (scannedId == ticketId) {
          _showMessage('QR de usuario válido');
          
          // Procesa el ticket después de la validación
          var result = await apiService.dispatchTicket(scannedId);
          _showMessage(result['message'] ?? 'Ticket procesado correctamente');

          // Reinicia la pantalla después del procesamiento exitoso
          resetScreen();
        } else {
          _showMessage('El ID de perfil no coincide con la bombona');
        }
      } else {
        _showMessage('No se pudo obtener los datos para la comparación');
      }
    } catch (e) {
      _showMessage('Error al escanear el QR de usuario: $e');
      logger.e('Error al escanear el QR de usuario: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear Bombona y Usuario'),
      ),
      body: Stack(
        children: [
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildScannerContent(context),
        ],
      ),
    );
  }

  Widget _buildScannerContent(BuildContext context) {
    return cylinderData == null
        ? _buildMobileScanner(context)
        : _buildCylinderInfo(context);
  }

  Widget _buildMobileScanner(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
      child: MobileScanner(
        onDetect: (BarcodeCapture barcodeCapture) {
          if (barcodeCapture.barcodes.isNotEmpty) {
            final Barcode barcode = barcodeCapture.barcodes.first;
            if (isUserScan) {
              _handleUserScan(barcode);
            } else {
              _handleScan(barcode);
            }
          }
        },
      ),
    );
  }

  Widget _buildCylinderInfo(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CylinderInfoWidget(
              cylinderData: cylinderData!,
              foregroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  cylinderData = null;
                  isUserScan = true; // Ahora se establece para escanear QR de usuario
                });
              },
              child: const Text('Escanear QR del Usuario'),
            ),
          ],
        ),
      ),
    );
  }
}

class CylinderInfoWidget extends StatelessWidget {
  final Map<String, dynamic> cylinderData;
  final Color foregroundColor;
  const CylinderInfoWidget({
    super.key, 
    required this.cylinderData,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailSection('Información de la Bombona', [
          'ID de la bombona: ${cylinderData['id']}',
          'Posición en la fila: ${cylinderData['queue_position']}',
          'Hora de la cita: ${cylinderData['time_position']}',
          'Fecha de reserva: ${cylinderData['reserved_date']}',
          'Fecha de la cita: ${cylinderData['appointment_date']}',
          'Estado: ${cylinderData['status']}',
        ]),
        _buildDetailSection('Detalles del Usuario', [
          'Usuario: ${cylinderData['profile']['user']['name']}',
          'ID del perfil: ${cylinderData['profile']['id']}',
          'Foto del usuario: ${cylinderData['profile']['photo_users']}',
        ]),
      ],
    );
  }

  Widget _buildDetailSection(String title, List<String> details) {
    return ExpansionTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      children: details.map((detail) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            detail,
            style: const TextStyle(fontSize: 18),
          ),
        );
      }).toList(),
    );
  }
}



// import 'dart:ffi';

// import 'package:flutter/material.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:zonix/features/GasTicket/dispatch_ticket_button/api/dispatch_ticket_service.dart';

// class DispatcherScreen extends StatefulWidget {
//   const DispatcherScreen({super.key});

//   @override
//   DispatcherScreenState createState() => DispatcherScreenState();
// }

// class DispatcherScreenState extends State<DispatcherScreen> {
//   late ApiService apiService;
//   String scannedData = '';
//   Map<String, dynamic>? cylinderData;
//   int? ticketId; // Definimos ticketId como variable de clase
//   bool isLoading = false;
//   bool isUserScan = false; // Flag to indicate user QR scan

//   @override
//   void initState() {
//     super.initState();
//     apiService = ApiService();
//   }

//   Future<void> _handleScan(Barcode barcode, {bool isCylinderScan = true}) async {
//     setState(() {
//       scannedData = barcode.rawValue?.trim() ?? 'Unknown';
//       isLoading = true;
//     });

//     try {
//       if (isCylinderScan) {
//         var result = await apiService.scanCylinder(scannedData);

//         setState(() {
//           cylinderData = (result['data'] is List && result['data'].isNotEmpty)
//               ? result['data'][0]
//               : result['data'];

//           ticketId = cylinderData?['id']; // Asignamos ticketId desde cylinderData
//           logger.i('Escaneo de bombona - ticketId: $ticketId');
//         });
//       } else {
//         _showMessage('Código escaneado no es válido para un ticket');
//       }
//     } catch (e) {
//       _showMessage('Error: $e');
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   void _showMessage(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
//   }

//   // Handle the User QR scan
//  Future<void> _handleUserScan(Barcode barcode) async {
//   setState(() {
//     isLoading = true;
//   });

//   try {
//     // Obtén el ID escaneado del usuario desde el QR y conviértelo a int
//     var scannedId = int.tryParse(barcode.rawValue?.trim() ?? '');
  

//     logger.i('Ticket ID77777777777777777777777777777777777777777777777777777777777777777777777777777777777777: $ticketId');
//     // Registro de los valores escaneados para depuración
//     logger.i('Ticket ID: $ticketId, Escaneado: $scannedId');
    
//     if (ticketId != null && scannedId != null) {
//       // Compara el ID escaneado con el ID almacenado en `cylinderData`
//       if (scannedId == ticketId) {
//             var result = await apiService.dispatchTicket(scannedId);
//             _showMessage(result['message']);
//       } else {
//         _showMessage('El ID de perfil no coincide con la bombona');
//       }
//     } else {
//       _showMessage('No se pudo obtener los datos para la comparación');
//     }
//   } catch (e) {
//     _showMessage('Error al escanear el QR de usuario: $e');
//     logger.e('Error al escanear el QR de usuario: $e');
//   } finally {
//     setState(() {
//       isLoading = false;
//     });
//   }
// }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Escanear Bombona y Usuario'),
//       ),
//       body: Stack(
//         children: [
//           isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : _buildScannerContent(context),
//         ],
//       ),
//     );
//   }

//   Widget _buildScannerContent(BuildContext context) {
//     return cylinderData == null
//         ? _buildMobileScanner(context)
//         : _buildCylinderInfo(context);
//   }

//   Widget _buildMobileScanner(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
//       child: MobileScanner(
//         onDetect: (BarcodeCapture barcodeCapture) {
//           if (barcodeCapture.barcodes.isNotEmpty) {
//             final Barcode barcode = barcodeCapture.barcodes.first;
//             if (isUserScan) {
//               _handleUserScan(barcode);
//             } else {
//               _handleScan(barcode);
//             }
//           }
//         },
//       ),
//     );
//   }

//   Widget _buildCylinderInfo(BuildContext context) {
//     return SingleChildScrollView(
//       child: Padding(
//         padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CylinderInfoWidget(
//               cylinderData: cylinderData!,
//               foregroundColor: Theme.of(context).brightness == Brightness.dark
//                   ? Colors.white
//                   : Colors.black,
//             ),
//             SizedBox(height: MediaQuery.of(context).size.height * 0.02),
//             ElevatedButton(
//               onPressed: () {
//                 setState(() {
//                   cylinderData = null;
//                   isUserScan = true; // Now set to scan for user QR
//                 });
//               },
//               child: const Text('Escanear QR del Usuario'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class CylinderInfoWidget extends StatelessWidget {
//   final Map<String, dynamic> cylinderData;
//   final Color foregroundColor;
//   const CylinderInfoWidget({
//     super.key, 
//     required this.cylinderData,
//     required this.foregroundColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildDetailSection('Información de la Bombona', [
//           'ID de la bombona: ${cylinderData['id']}',
//           'Posición en la fila: ${cylinderData['queue_position']}',
//           'Hora de la cita: ${cylinderData['time_position']}',
//           'Fecha de reserva: ${cylinderData['reserved_date']}',
//           'Fecha de la cita: ${cylinderData['appointment_date']}',
//           'Estado: ${cylinderData['status']}',
//         ]),
//         _buildDetailSection('Detalles del Usuario', [
//           'Usuario: ${cylinderData['profile']['user']['name']}',
//           'ID del perfil: ${cylinderData['profile']['id']}',
//           'Foto del usuario: ${cylinderData['profile']['photo_users']}',
//         ]),
//       ],
//     );
//   }

//   Widget _buildDetailSection(String title, List<String> details) {
//     return ExpansionTile(
//       title: Text(
//         title,
//         style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//       ),
//       children: details.map((detail) {
//         return Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//           child: Text(
//             detail,
//             style: const TextStyle(fontSize: 18),
//           ),
//         );
//       }).toList(),
//     );
//   }
// }
