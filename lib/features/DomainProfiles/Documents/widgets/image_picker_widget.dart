import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerWidget extends StatelessWidget {
  final ValueSetter<String?> onFrontImageSelected;
  final ValueSetter<String?> onBackImageSelected;

  const ImagePickerWidget({super.key,
    required this.onFrontImageSelected,
    required this.onBackImageSelected,
  });

  Future<void> _pickImage(
      ImageSource source, ValueSetter<String?> onImageSelected) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) onImageSelected(pickedFile.path);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ElevatedButton(
          onPressed: () => _pickImage(ImageSource.camera, onFrontImageSelected),
          child: const Text('Imagen Frontal'),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: () => _pickImage(ImageSource.camera, onBackImageSelected),
          child: const Text('Imagen Trasera'),
        ),
      ],
    );
  }
}
