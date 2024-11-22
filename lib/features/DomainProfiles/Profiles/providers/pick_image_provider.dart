import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

class CameraPickerExample extends StatefulWidget {
  const CameraPickerExample({super.key});

  @override
  CameraPickerExampleState createState() => CameraPickerExampleState();
}

class CameraPickerExampleState extends State<CameraPickerExample> {
  String? _capturedImagePath;

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final compressedPath = await _compressImage(pickedFile.path);
      setState(() {
        _capturedImagePath = compressedPath;
      });
    }
  }

  Future<String?> _compressImage(String filePath) async {
    final imageFile = File(filePath);
    final originalImage = img.decodeImage(await imageFile.readAsBytes());

    if (originalImage == null) return null;

    // Comprimir la imagen
    const  quality =  85;
    final compressedBytes = img.encodeJpg(originalImage, quality: quality);

    // Guardar la imagen comprimida en un nuevo archivo temporal
    final compressedFile = await File('${imageFile.parent.path}/compressed_${imageFile.uri.pathSegments.last}')
        .writeAsBytes(compressedBytes);

    return compressedFile.path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tomar Foto')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_capturedImagePath != null)
              Image.file(File(_capturedImagePath!), height: 300), // Mostrar la foto capturada
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _takePhoto,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Abrir Cámara'),
            ),
          ],
        ),
      ),
    );
  }
}
