import 'dart:io';
import 'package:flutter/material.dart';
import 'package:zonix/features/DomainProfiles/Documents/api/document_service.dart';
import 'package:zonix/features/DomainProfiles/Documents/widgets/mobile_scanner_xz.dart';
import '../models/document.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart'; // Importar para usar FilteringTextInputFormatter
import 'package:logger/logger.dart';
import 'package:image/image.dart' as img; // Importar el paquete de imagen
import 'package:zonix/features/utils/user_provider.dart';
import 'package:provider/provider.dart';

final logger = Logger();

final documentService = DocumentService();
class CreateDocumentScreen extends StatefulWidget {
  final int userId;

  const CreateDocumentScreen({super.key, required this.userId});

  @override
  CreateDocumentScreenState createState() => CreateDocumentScreenState();
}

class CreateDocumentScreenState extends State<CreateDocumentScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedType;
  int? _number;
  String? _frontImage;
  String? _backImage;
  String? _rifUrl;
  String? _taxDomicile;
  DateTime? _issuedAt;
  DateTime? _expiresAt;
  int? _receiptN;



  Future<void> _selectDate(BuildContext context, ValueChanged<DateTime?> onDateSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) onDateSelected(picked);
  }


Future<void> _pickImage(ImageSource source, ValueSetter<String?> onImageSelected) async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: source);
  
  if (pickedFile != null) {
    // Comprimir la imagen antes de guardarla
    final compressedImage = await _compressImage(pickedFile.path);
    
    setState(() {
      onImageSelected(compressedImage);
    });
  }
}

// Future<String?> _compressImage(String filePath) async {
//   // Cargar la imagen
//   final imageFile = File(filePath);
//   final originalImage = img.decodeImage(await imageFile.readAsBytes());

//   if (originalImage == null) return null;

//   // Comprimir la imagen
//   int quality = 85; // Establece un porcentaje de calidad
//   List<int> compressedBytes = img.encodeJpg(originalImage, quality: quality);
  
//   // Guardar la imagen comprimida en un nuevo archivo temporal
//   final compressedImageFile = await File('${imageFile.parent.path}/compressed_${imageFile.uri.pathSegments.last}').writeAsBytes(compressedBytes);

//   return compressedImageFile.path; // Devuelve la ruta del archivo comprimido
// }

Future<String?> _compressImage(String filePath) async {
  try {
    final imageFile = File(filePath);

    // Verificar si la imagen ya es menor a 2 MB
    if (await imageFile.length() <= 2 * 1024 * 1024) {
      return filePath; // Devolver la misma imagen si no necesita compresión
    }

    final originalImage = img.decodeImage(await imageFile.readAsBytes());
    if (originalImage == null) {
      debugPrint("No se pudo decodificar la imagen.");
      return null; // Si no se puede decodificar, devuelve null
    }

    String extension = filePath.split('.').last.toLowerCase();
    int quality = 85; // Calidad inicial
    List<int> compressedBytes;

    if (extension == 'png') {
      // Compresión para PNG
      compressedBytes = img.encodePng(originalImage, level: 6);
    } else {
      // Compresión para JPG
      compressedBytes = img.encodeJpg(originalImage, quality: quality);

      // Reducir calidad iterativamente si es mayor a 2 MB
      while (compressedBytes.length > 2 * 1024 * 1024 && quality > 10) {
        quality -= 5;
        compressedBytes = img.encodeJpg(originalImage, quality: quality);
      }
    }

    // Guardar la imagen comprimida
    final compressedImageFile = await File(
      '${imageFile.parent.path}/compressed_${imageFile.uri.pathSegments.last}',
    ).writeAsBytes(compressedBytes);

    debugPrint("Imagen comprimida guardada en: ${compressedImageFile.path}");
    return compressedImageFile.path;

  } catch (e) {
    debugPrint("Error al comprimir la imagen: $e");
    return null;
  }
}

// Future<String?> _compressImage(String filePath) async {
//   try {
//     final imageFile = File(filePath);

//     // Verificar si la imagen ya es menor a 1.5  MG
//     if (await imageFile.length() <= 1.5 * 1024 * 1024) {  // 1.5  MG
//       return filePath; // Devolver la misma imagen si no necesita compresión
//     }

//     final originalImage = img.decodeImage(await imageFile.readAsBytes());
//     if (originalImage == null) {
//       debugPrint("No se pudo decodificar la imagen.");
//       return null; // Si no se puede decodificar, devuelve null
//     }

//     String extension = filePath.split('.').last.toLowerCase();
//     int quality = 85; // Calidad inicial
//     List<int> compressedBytes;

//     if (extension == 'png') {
//       // Compresión para PNG
//       compressedBytes = img.encodePng(originalImage, level: 6);
//     } else {
//       // Compresión para JPG
//       compressedBytes = img.encodeJpg(originalImage, quality: quality);

//       // Reducir calidad iterativamente hasta que el tamaño sea menor a 1.5  MG (o 100 KB si lo deseas)
//       while (compressedBytes.length > 1.5 * 1024 * 1024 && quality > 10) {  // 1.5  MG
//         quality -= 5;
//         compressedBytes = img.encodeJpg(originalImage, quality: quality);
//       }
//     }

//     // Guardar la imagen comprimida
//     final compressedImageFile = await File(
//       '${imageFile.parent.path}/compressed_${imageFile.uri.pathSegments.last}',
//     ).writeAsBytes(compressedBytes);

//     debugPrint("Imagen comprimida guardada en: ${compressedImageFile.path}");
//     return compressedImageFile.path;

//   } catch (e) {
//     debugPrint("Error al comprimir la imagen: $e");
//     return null;
//   }
// }


// Future<String?> _compressImage(String filePath) async {
//   try {
//     final imageFile = File(filePath);

//     // Verificar si la imagen ya es menor a 1.5 MB (1.5 * 1024 * 1024 bytes)
//     if (await imageFile.length() <= 1.5 * 1024 * 1024) {
//       return filePath; // Devolver la misma imagen si no necesita compresión
//     }

//     final originalImage = img.decodeImage(await imageFile.readAsBytes());
//     if (originalImage == null) {
//       debugPrint("No se pudo decodificar la imagen.");
//       return null; // Si no se puede decodificar, devuelve null
//     }

//     String extension = filePath.split('.').last.toLowerCase();
//     int quality = 85; // Calidad inicial para JPG
//     List<int> compressedBytes;

//     if (extension == 'png') {
//       // Compresión para PNG
//       compressedBytes = img.encodePng(originalImage, level: 6);
//     } else {
//       // Compresión para JPG
//       compressedBytes = img.encodeJpg(originalImage, quality: quality);

//       // Reducir calidad iterativamente hasta que el tamaño sea menor a 1.5 MB
//       while (compressedBytes.length > 1.5 * 1024 * 1024 && quality > 10) {
//         quality -= 5;
//         compressedBytes = img.encodeJpg(originalImage, quality: quality);
//       }
//     }

//     // Crear una ruta para la imagen comprimida, evitando sobrescribir la original
//     final compressedImageFile = await File(
//       '${imageFile.parent.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.${extension}',
//     ).writeAsBytes(compressedBytes);

//     debugPrint("Imagen comprimida guardada en: ${compressedImageFile.path}");
//     return compressedImageFile.path;

//   } catch (e) {
//     debugPrint("Error al comprimir la imagen: $e");
//     return null;
//   }
// }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Documento')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTypeDropdown(),
              const SizedBox(height: 16.0),
              if (_selectedType != null) _buildFieldsByType(),
              const SizedBox(height: 16.0),
     
              // ElevatedButton(
              //   onPressed: _saveDocument,
              //   child: const Text('Guardar Documento'),
              // ),
            ],
          ),
        ),
      ),
floatingActionButton: Column(
  mainAxisSize: MainAxisSize.min, // Minimiza el espacio ocupado por la columna
  children: [
    SizedBox(
      width: MediaQuery.of(context).size.width * 0.8, // 80% del ancho de la pantalla
      child: FloatingActionButton.extended(
        onPressed: _saveDocument,
        tooltip: 'Guardar Documento',
        icon: const Icon(Icons.save),
        label: const Text('Guardar Documento'),
      ),
    ),
    const SizedBox(height: 16.0), // Espaciador
  ],
),
floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,


    );
  }

  Widget _buildTypeDropdown() {
    final Map<String, String> typeTranslations = {
      'ci': 'Cédula de Identidad',
      'passport': 'Pasaporte',
      'rif': 'RIF',
      'neighborhood_association': 'Asociación de Vecinos',
    };

    return DropdownButtonFormField<String>(
      value: _selectedType,
      items: typeTranslations.entries
          .map((entry) => DropdownMenuItem(value: entry.key, child: Text(entry.value)))
          .toList(),
      onChanged: (value) => setState(() => _selectedType = value),
      decoration: const InputDecoration(labelText: 'Tipo de Documento'),
      validator: (value) => value == null ? 'Seleccione un tipo' : null,
    );
  }

  Widget _buildFieldsByType() {
    switch (_selectedType) {
      case 'ci':
        return _buildCIFields();
      case 'passport':
        return _buildPassportFields();
      case 'rif':
        return _buildRIFFields();
      case 'neighborhood_association':
        return _buildAssociationFields();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildCIFields() {
    return Column(
      children: [
        _buildNumberField(),
        const SizedBox(height: 16.0),
        _buildImageRow('Imagen Frontal', 'Imagen Trasera'),
        _showCapturedImages(), // Mostrar imágenes capturadas
        _buildCommonFields(),
      ],
    );
  }

  Widget _buildPassportFields() {
    return Column(
      children: [
        _buildNumberField(),
        _buildReceiptNField(),
        const SizedBox(height: 16.0),
        _buildImageRow('Imagen Frontal', 'Imagen Trasera'),
        _showCapturedImages(),
        _buildCommonFields(),
      ],
    );
  }

Widget _buildRIFFields() {
  return Column(
    children: [
      _buildNumberField(),
      _buildReceiptNField(),
      _buildQRScannerField(),  // Reemplaza el campo de URL RIF por el botón
      _buildTextField('Domicilio Fiscal', (value) => _taxDomicile = value),
      const SizedBox(height: 16.0),
      _buildImageRow('Imagen Frontal', 'Imagen Trasera'),
      _showCapturedImages(),
      _buildCommonFields(),
    ],
  );
}


  Widget _buildAssociationFields() {
    return Column(
      children: [
        _buildReceiptNField(),
        _buildTextField('Domicilio Fiscal', (value) => _taxDomicile = value),
        const SizedBox(height: 16.0),
        _buildImageRow('Imagen Frontal', 'Imagen Trasera'),
        _showCapturedImages(),
        _buildCommonFields(),
      ],
    );
  }

  Widget _buildQRScannerField() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // const Text('URL RIF', style: TextStyle(fontSize: 16)),
      const SizedBox(height: 16.0),
      ElevatedButton.icon(
        onPressed: _scanQRCode,
        icon: const Icon(Icons.qr_code_scanner, size: 30), // Aumenta el tamaño del icono
        label: const Text(
          'Escanear QR RIF',
          style: TextStyle(fontSize: 18), // Aumenta el tamaño del texto
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0), // Aumenta el padding
          minimumSize: const Size(double.infinity, 60), // Aumenta la altura mínima del botón
        ),
      ),
      if (_rifUrl != null) ...[
        const SizedBox(height: 16.0),
        Text('URL escaneada: $_rifUrl'),
      ]
    ],
  );
}



  Widget _buildCommonFields() {
    return Column(
      children: [
        _buildDateField('Fecha de Emisión', _issuedAt, (date) => _issuedAt = date),
        const SizedBox(height: 16.0),
        _buildDateField('Fecha de Expiración', _expiresAt, (date) => _expiresAt = date),
      ],
    );
  }

  Widget _showCapturedImages() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Alinea los elementos horizontalmente
      children: [
        if (_frontImage != null)
          Column(
            children: [
              Image.file(File(_frontImage!), height: 150),
              const Text('Frontal', style: TextStyle(fontSize: 12)), // Etiqueta para la imagen frontal
            ],
          ),
        if (_backImage != null)
          Column(
            children: [
              Image.file(File(_backImage!), height: 150),
              const Text('Trasera', style: TextStyle(fontSize: 12)), // Etiqueta para la imagen trasera
            ],
          ),
      ],
    );
  }

  Widget _buildImageRow(String frontLabel, String backLabel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: _buildImagePicker(frontLabel, (value) => _frontImage = value),
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: _buildImagePicker(backLabel, (value) => _backImage = value),
        ),
      ],
    );
  }

  Widget _buildImagePicker(String label, ValueSetter<String?> onSaved) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(100, 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        backgroundColor: Colors.blueAccent[700],
      ),
      icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
      onPressed: () => _pickImage(ImageSource.camera, onSaved),
    );
  }

  Widget _buildNumberField() {
    return _buildTextField(
      'Número',
      (value) => _number = int.tryParse(value ?? ''),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Permitir solo dígitos
      keyboardType: TextInputType.number, // Teclado numérico
    );
  }

  Widget _buildReceiptNField() {
    return _buildTextField(
      'N° Comprobante',
      (value) => _receiptN = int.tryParse(value ?? ''),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Permitir solo dígitos
      keyboardType: TextInputType.number, // Teclado numérico
    );
  }

  Widget _buildTextField(String label, FormFieldSetter<String> onSaved, {List<TextInputFormatter>? inputFormatters, TextInputType? keyboardType}) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      onSaved: onSaved,
      inputFormatters: inputFormatters, // Aplicar inputFormatters
      keyboardType: keyboardType, // Establecer el tipo de teclado
    );
  }

  Widget _buildDateField(String label, DateTime? date, ValueChanged<DateTime?> onDateSelected) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () => _selectDate(context, (picked) => setState(() => onDateSelected(picked))),
        ),
      ),
      readOnly: true,
      validator: (value) => date == null ? 'Seleccione una fecha' : null,
      controller: TextEditingController(text: date != null ? '${date.toLocal()}'.split(' ')[0] : ''),
    );
  }

  File? _getFileFromPath(String? path) {
  if (path == null || path.isEmpty) return null;
  return File(path);
}

Future<void> _scanQRCode() async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const QRScannerScreen(),
    ),
  );

  // Comprobación del resultado
  if (result != null && result is String) {
    setState(() {
      _rifUrl = result;  // Asegúrate de que 'result' sea una cadena no nula
    });
  } else {
    // Manejo de error si el resultado es nulo o no es una cadena
    logger.e('Escaneo cancelado o fallido.');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Escaneo cancelado o fallido.')),
    );
  }
}


int _saveCounter = 0; // Contador para guardar documentos, inicia en 0

Future<void> _saveDocument() async {
  if (_formKey.currentState!.validate()) {
    _formKey.currentState!.save();
    try {
      // Verificar el tamaño de la imagen antes de enviarla
      if (_frontImage != null && await _isImageSizeValid(_frontImage)) {
        // Continuar con el guardado del documento
        Document document = Document(
          id: 0,
          type: _selectedType,
          number: _number?.toString(),
          receiptN: _receiptN,
          rifUrl: _rifUrl,
          taxDomicile: _taxDomicile,
          frontImage: _frontImage,
          backImage: _backImage,
          issuedAt: _issuedAt,
          expiresAt: _expiresAt,
          approved: false,
          status: true,
        );

        await documentService.createDocument(
          document,
          widget.userId,
          frontImageFile: _getFileFromPath(document.frontImage),
          backImageFile: _getFileFromPath(document.backImage),
        );

        if (mounted) { // Verifica si el widget aún está montado
          // Incrementa el contador después de cada guardado exitoso
          setState(() {
            _saveCounter++;
          });

          // Verifica si el contador ha alcanzado 3 después del incremento
          if (_saveCounter == 3) {
            Provider.of<UserProvider>(context, listen: false).setDocumentCreated(true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Límite alcanzado. Puedes avanzar al siguiente paso.')),
            );
            // Aquí podrías redirigir a otra pantalla o realizar otra acción adicional
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Documento guardado exitosamente')),
            );
          }

          Navigator.of(context).pop();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('La imagen frontal supera los 2 MB.')),
        );
      }
    } catch (e) {
      logger.e('Error al guardar el documento: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar el documento: $e')),
      );
    }
  }
}

Future<bool> _isImageSizeValid(String? path) async {
  if (path == null) return false;
  final file = File(path);
  final sizeInBytes = await file.length();
  return sizeInBytes <= 2048 * 1024; // 2048 KB
}



}
