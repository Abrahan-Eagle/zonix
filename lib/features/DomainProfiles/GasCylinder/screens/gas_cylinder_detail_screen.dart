import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:printing/printing.dart';
import 'package:zonix/features/DomainProfiles/GasCylinder/models/gas_cylinder.dart';

class GasCylinderDetailScreen extends StatelessWidget {
  final GasCylinder cylinder;

  const GasCylinderDetailScreen({super.key, required this.cylinder});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Bombona'),
      ),
      body: _buildCylinderDetails(context),
      floatingActionButton: Stack(
        children: [
          // Botón de Generar PDF solo si está aprobado
          if (cylinder.approved)
            Positioned(
              right: 10,
              bottom: 10,
              child: FloatingActionButton(
                onPressed: () async {
                  try {
                    // Generar el PDF con el QR
                    final pdfBytes = await generatePDFWithQR(cylinder.gasCylinderCode);

                    // Mostrar el PDF en una vista previa
                    await Printing.layoutPdf(
                      onLayout: (PdfPageFormat format) async => pdfBytes,
                    );
                  } catch (e) {
                    // Manejar errores
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  }
                },
                backgroundColor: Colors.green, // Color distintivo para el botón
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.qr_code, size: 40), // Ícono de QR
                    // Text(
                    //   'Generar PDF',
                    //   style: TextStyle(fontSize: 10, color: Colors.white),
                    // ), // Texto dentro del botón
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Método para generar el QR con el gasCylinderCode
  Future<Uint8List> _generateQRImage(String data) async {
    final qrValidationResult = QrValidator.validate(
      data: data,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.Q,
    );
    if (qrValidationResult.status != QrValidationStatus.valid) {
      throw Exception('Error generando QR');
    }

    final qrCode = qrValidationResult.qrCode!;
    final painter = QrPainter.withQr(
      qr: qrCode,
      gapless: true,
      color: const Color(0xFF000000),
      emptyColor: const Color(0xFFFFFFFF),
    );

    final picData = await painter.toImageData(200, format: ui.ImageByteFormat.png);
    return picData!.buffer.asUint8List();
  }

  // Método para generar el PDF con el QR
  Future<Uint8List> generatePDFWithQR(String data) async {
    final pdf = pw.Document();

    // Obtener el QR como imagen
    final qrBytes = await _generateQRImage(data);

    // Convertir los bytes del QR en imagen para el PDF
    final qrImagePDF = pw.MemoryImage(qrBytes);

    // Crear el PDF
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Center(
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text('Código QR generado', style: const pw.TextStyle(fontSize: 20)),
              pw.SizedBox(height: 20),
              // Cambiar el tamaño de la imagen a 1024x1024
              pw.Image(qrImagePDF, width: 512, height: 512),
            ],
          ),
        ),
      ),
    );

    return pdf.save();
  }

  Widget _buildCylinderDetails(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          _buildBackgroundImage(context), // Imagen de fondo
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailItem(context, 'Código: ${cylinder.gasCylinderCode}', isHeader: true),
                _buildDetailItem(context, 'Cantidad: ${cylinder.cylinderQuantity ?? 'N/A'}'),
                _buildDetailItem(
                  context,
                  'Estado: ${cylinder.approved ? 'Aprobada' : 'No Aprobada'}',
                  textColor: cylinder.approved ? Colors.green : Colors.red,
                ),
                _buildDetailItem(context, 'Tipo de cilindro: ${cylinder.cylinderType ?? 'N/A'}'),
                _buildDetailItem(context, 'Tamaño de cilindro: ${cylinder.cylinderWeight ?? 'N/A'}'),
                _buildDetailItem(context, 'Fecha de producción: ${_formatDate(cylinder.manufacturingDate)}'),
                _buildDetailItem(context, 'Fecha de Creación: ${_formatDate(cylinder.createdAt)}'),
                const SizedBox(height: 20),
                _buildImageButton(context), // Botón de imagen
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageButton(BuildContext context) {
    return Center(
      child: IconButton(
        iconSize: 100,
        icon: const Icon(Icons.image, color: Colors.blue),
        onPressed: () => _showImageDialog(context),
      ),
    );
  }

  void _showImageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(10), // Reduce los márgenes del diálogo
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9, // 90% del ancho de la pantalla
            height: MediaQuery.of(context).size.height * 0.7, // 70% de la altura
            child: Column(
              children: [
                Expanded(
                  child: Image.network(
                    cylinder.photoGasCylinder ?? '', // URL de la imagen
                    fit: BoxFit.contain, // Ajusta la imagen sin recortarla
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Text('Imagen no disponible'),
                      );
                    },
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cerrar', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(BuildContext context, String text,
      {bool isHeader = false, Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: isHeader ? 20 : 16,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: textColor ?? Theme.of(context).textTheme.bodyMedium?.color,
        ),
      ),
    );
  }

  Widget _buildBackgroundImage(BuildContext context) {
    Color logoColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;

    return Positioned(
      right: -110,
      bottom: -30,
      child: SizedBox(
        width: 425,
        height: 425,
        child: Opacity(
          opacity: 0.3,
          child: Image.asset(
            'assets/images/splash_logo_dark.png',
            fit: BoxFit.cover,
            color: logoColor,
            colorBlendMode: BlendMode.modulate,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return date.toLocal().toString().split(' ')[0];
  }
}
