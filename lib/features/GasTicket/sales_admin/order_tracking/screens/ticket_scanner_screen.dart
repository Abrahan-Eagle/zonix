import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:zonix/features/GasTicket/sales_admin/order_tracking/api/sales_admin_service.dart';
import 'package:zonix/features/GasTicket/gas_button/models/gas_ticket.dart';

import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class TicketScannerScreen extends StatefulWidget {
  const TicketScannerScreen({super.key});

  @override
  TicketScannerScreenState createState() => TicketScannerScreenState();
}

class TicketScannerScreenState extends State<TicketScannerScreen> {
  late ApiService apiService;
  String scannedData = '';
  GasTicket? ticketData;

  @override
  void initState() {
    super.initState();
    apiService = ApiService();
  }

  void _onScan(Barcode barcode) async {
    setState(() {
      scannedData = barcode.rawValue ?? 'Unknown';
    });

    try {
      var result = await apiService.verifyTicket(int.parse(scannedData));
      setState(() {
        ticketData = GasTicket.fromJson(result['data']); // Mapea al modelo
      });
    } catch (e) {
      _showMessage('Error al verificar el ticket');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _markAsWaiting() async {
    if (ticketData != null) {
      try {
        var result = await apiService.markAsWaiting(ticketData!.id);
        _showMessage(result['message']);
        setState(() {
          ticketData = null;
        });
      } catch (e) {
        _showMessage('Error al marcar como esperando');
      }
    }
  }

  void _cancelTicket() async {
    if (ticketData != null) {
      try {
        var result = await apiService.cancelTicket(ticketData!.id);
        _showMessage(result['message']);
        setState(() {
          ticketData = null;
        });
      } catch (e) {
        _showMessage('Error al cancelar el ticket');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: ticketData == null
          ? MobileScanner(
              onDetect: (BarcodeCapture barcodeCapture) {
                if (barcodeCapture.barcodes.isNotEmpty) {
                  final Barcode barcode = barcodeCapture.barcodes.first;
                  _onScan(barcode);
                }
              },
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: screenWidth,
                    decoration: BoxDecoration(
                      color:
                          isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: screenWidth * 0.05,
                        horizontal: screenWidth * 0.06,
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: screenWidth * 0.25,
                                height: screenWidth * 0.25,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(40),
                                  child: Image.network(
                                    ticketData?.photoUser ??
                                        'https://images.unsplash.com/photo-1580619265140-1671b43697ca?w=500&h=500',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.05),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${ticketData?.firstName ?? ''} ${ticketData?.lastName ?? ''}',
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: screenWidth * 0.06,
                                      fontWeight: FontWeight.w900,
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${ticketData?.operatorName.join(', ') ?? ''} - ${ticketData?.phoneNumbers.join(', ') ?? ''}',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: screenWidth * 0.04,
                                      color: isDarkMode
                                          ? Colors.grey[400]
                                          : Colors.grey[800],
                                    ),
                                  ),
                                  Text(
                                    ticketData?.addresses.isNotEmpty ?? false
                                        ? ticketData!.addresses.first
                                        : 'Dirección no disponible',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: screenWidth * 0.04,
                                      color: isDarkMode
                                          ? Colors.grey[400]
                                          : Colors.grey[800],
                                    ),
                                  ),

                  Row(
                    children: [
                      Text(
                        'Estación:',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          color:
                              Theme.of(context).brightness == Brightness.dark
                                  ? const Color(0xFF57636C)
                                  : Colors.black,
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                    Text(
                      ticketData?.stationCode ?? 'No station code available', // Proporcionar valor por defecto si es null
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        color: isDarkMode ? Colors.white : const Color(0xFF57636C),
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    ],
                  ),



                               ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                24, 0, 24, 0),
                            child: Material(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Container(
                                width: screenWidth,
                                decoration: BoxDecoration(
                                  color: isDarkMode
                                      ? const Color(0xFF2C2C2C)
                                      : Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 12,
                                      color: isDarkMode
                                          ? Colors.black26
                                          : const Color(0x33000000),
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      16, 16, 16, 16),
                                  child: Column(
                                    children: [
                                      Text(
                                        'Documento de Identidad',
                                        style: TextStyle(
                                          fontFamily: 'Inter Tight',
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: isDarkMode
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Tipo:',
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              color: isDarkMode
                                                  ? Colors.grey[400]
                                                  : Colors.grey[800],
                                            ),
                                          ),
                                          Text(
                                            translateDocumentType(ticketData!
                                                    .documentType.isNotEmpty
                                                ? ticketData!.documentType.first
                                                : ''),
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              color: isDarkMode
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Número:',
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              color: isDarkMode
                                                  ? Colors.grey[400]
                                                  : Colors.grey[800],
                                            ),
                                          ),
                                          Text(
                                            '${translateDocumentType2(ticketData!.documentType.isNotEmpty ? ticketData!.documentType.first : '')} '
                                             '${(ticketData?.documentNumberCi.isNotEmpty ?? false) ? ticketData?.documentNumberCi.join(', ') : 'No CI available'}',
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              color: isDarkMode
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Container(
                                        width: screenWidth,
                                        height: 200,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.network(
                                            ticketData?.documentImages.isNotEmpty == true
                                                ? ticketData!.documentImages.first
                                                : 'https://images.unsplash.com/photo-1580619265140-1671b43697ca?w=500&h=500',
                                            width: MediaQuery.of(context).size.width,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (context, child,
                                                loadingProgress) {
                                              if (loadingProgress == null) return child;
                                              return Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  value: loadingProgress.expectedTotalBytes != null
                                                      ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                                      : null,
                                                ),
                                              );
                                            },
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    const Icon(
                                              Icons.broken_image,
                                              size: 50,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                24, 0, 24, 0),
                            child: Material(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? const Color(0xFF2C2C2C)
                                      : Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 12,
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.black26
                                          : const Color(0x33000000),
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      16, 16, 16, 16),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Text(
                                        'Detalles del Ticket',
                                        style: TextStyle(
                                          fontFamily: 'Inter Tight',
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Posición:',
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? Colors.grey[400]
                                                  : Colors.grey[800],
                                            ),
                                          ),
                                          Text(
                                            ticketData?.queuePosition ?? '',
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Fecha de Reserva:',
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? Colors.grey[400]
                                                  : Colors.grey[800],
                                            ),
                                          ),
                                          Text(
                                            ticketData?.reservedDate != null
                                                ? _formatDate(
                                                    ticketData!.reservedDate)
                                                : 'Fecha no disponible',
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Fecha de Cita:',
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? Colors.grey[400]
                                                  : Colors.grey[800],
                                            ),
                                          ),
                                          Text(
                                            ticketData?.appointmentDate != null
                                                ? _formatDate(
                                                    ticketData!.appointmentDate)
                                                : 'Fecha no disponible',
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Fecha de Vencimiento:',
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? Colors.grey[400]
                                                  : Colors.grey[800],
                                            ),
                                          ),
                                          Text(
                                            ticketData?.expiryDate != null
                                                ? _formatDate(
                                                    ticketData!.expiryDate)
                                                : 'Fecha no disponible',
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                24, 0, 24, 0),
                            child: Material(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? const Color(0xFF2C2C2C)
                                      : Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 12,
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.black26
                                          : const Color(0x33000000),
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      16, 16, 16, 16),
                                  child: Column(
                                    children: [
                                      Text(
                                        'Detalles de la Bombona',
                                        style: TextStyle(
                                          fontFamily: 'Inter Tight',
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 16), 
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Código:',
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? Colors.grey[400]
                                                  : Colors.grey[800],
                                            ),
                                          ),
                                          Text(
                                           '${ticketData?.gasCylinderCode}',
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Cantidad:',
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? Colors.grey[400]
                                                  : Colors.grey[800],
                                            ),
                                          ),
                                          Text(
                                            '${ticketData?.cylinderQuantity ?? '0'} unidades',
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Tipo de Boquilla:',
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? Colors.grey[400]
                                                  : Colors.grey[800],
                                            ),
                                          ),
                                          Text(
                                            ticketData?.cylinderType == 'small'
                                                ? 'Boca Pequeña'
                                                : 'Boca Ancha',
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Peso:',
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? Colors.grey[400]
                                                  : Colors.grey[800],
                                            ),
                                          ),
                                          Text(
                                            '10 kg',
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Fecha de Fabricación:',
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? Colors.grey[400]
                                                  : Colors.grey[800],
                                            ),
                                          ),
                                          Text(
                                            ticketData?.manufacturingDate !=
                                                    null
                                                ? _formatDate(ticketData!
                                                    .manufacturingDate)
                                                : 'Fecha no disponible',
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                          height:
                                              12), // Espaciado antes de la imagen
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: 200,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          // child: Image.network(
                                          //   'https://images.unsplash.com/photo-1634745291366-4e4d79b2497a?w=500&h=500',
                                          //   width: MediaQuery.of(context).size.width,
                                          //   fit: BoxFit.cover,
                                          // ),

                                          child: Image.network(
                                            ticketData?.gasCylinderPhoto ??
                                                'https://images.unsplash.com/photo-1580619265140-1671b43697ca?w=500&h=500',
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (context, child,
                                                loadingProgress) {
                                              if (loadingProgress == null) return child; // Imagen cargada
                                              return Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  value: loadingProgress
                                                              .expectedTotalBytes !=
                                                          null
                                                      ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          (loadingProgress
                                                                  .expectedTotalBytes ??
                                                              1)
                                                      : null,
                                                ),
                                              ); // Indicador mientras se carga
                                            },
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    const Icon(
                                              Icons.broken_image,
                                              size: 50,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                          height: 12), // Espaciado final
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),




                          
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton(
                                onPressed: _cancelTicket,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                    horizontal: 48,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ),
                                child: const Text(
                                  'Cancelar',
                                  style: TextStyle(
                                    fontFamily: 'Inter Tight',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: _markAsWaiting,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                    horizontal: 48,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ),
                                child: const Text(
                                  'Comprar',
                                  style: TextStyle(
                                    fontFamily: 'Inter Tight',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

String _formatDate(String date) {
  try {
    // Inicializar configuración en español
    initializeDateFormatting('es', null);

    final parsedDate = DateTime.parse(date);
    // Formato de fecha numérico
    return DateFormat('dd/MM/yyyy').format(parsedDate);
  } catch (e) {
    return date; // Retorna la cadena original si ocurre un error
  }
}

String translateDocumentType(String type) {
  switch (type) {
    case 'ci':
      return 'Cédula';
    case 'rif':
      return 'REGISTRO DE INFORMACIÓN FISCAL';
    case 'neighborhood_association':
      return 'ASOCIACIÓN DE VECINOS';
    case 'passport':
      return 'PASAPORTE';
    default:
      return 'DESCONOCIDO';
  }
}

String translateDocumentType2(String type) {
  switch (type) {
    case 'ci':
      return 'V';
    case 'rif':
      return 'RIF';
    case 'neighborhood_association':
      return 'AV';
    case 'passport':
      return 'P';
    default:
      return 'DESCONOCIDO';
  }
}
