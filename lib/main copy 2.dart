import 'dart:typed_data';
import 'dart:ui' as ui; // Importar para trabajar con renderización
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:printing/printing.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR a PDF',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const QRToPDFScreen(),
    );
  }
}

class QRToPDFScreen extends StatelessWidget {
  const QRToPDFScreen({super.key});
  final String qrData = "https://google.com"; // Datos del QR

  // Método para renderizar el widget QR en una imagen
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generar PDF con QR')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            try {
              // Generar el PDF con el QR
              final pdfBytes = await generatePDFWithQR(qrData);

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
          child: const Text('Generar PDF'),
        ),
      ),
    );
  }
}
