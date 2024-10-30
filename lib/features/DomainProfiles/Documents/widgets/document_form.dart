import 'package:flutter/material.dart';
import 'image_picker_widget.dart';

class DocumentForm {
  static Widget buildCIFields({
    required ValueSetter<String?> onNumberSaved,
    required Function(String?, String?) onImageSelected,
  }) {
    return Column(
      children: [
        _buildNumberField(onNumberSaved),
        const SizedBox(height: 16),
        ImagePickerWidget(
          onFrontImageSelected: (image) => onImageSelected(image, null),
          onBackImageSelected: (image) => onImageSelected(null, image),
        ),
      ],
    );
  }

  static Widget buildPassportFields({
    required ValueSetter<String?> onNumberSaved,
    required ValueSetter<String?> onReceiptNSaved,
    required Function(String?, String?) onImageSelected,
  }) {
    return Column(
      children: [
        _buildNumberField(onNumberSaved),
        _buildReceiptField(onReceiptNSaved),
        ImagePickerWidget(
          onFrontImageSelected: (image) => onImageSelected(image, null),
          onBackImageSelected: (image) => onImageSelected(null, image),
        ),
      ],
    );
  }

  static Widget buildRIFFields({
    required ValueSetter<String?> onNumberSaved,
    required ValueSetter<String?> onReceiptNSaved,
    required ValueSetter<String?> onRifUrlScanned,
    required Function(String?, String?) onImageSelected,
  }) {
    return Column(
      children: [
        _buildNumberField(onNumberSaved),
        _buildReceiptField(onReceiptNSaved),
        ElevatedButton(
          onPressed: () async {
            final url = await _scanQRCode(); // Implementa la lógica de escaneo aquí.
            onRifUrlScanned(url);
          },
          child: const Text('Escanear QR RIF'),
        ),
        ImagePickerWidget(
          onFrontImageSelected: (image) => onImageSelected(image, null),
          onBackImageSelected: (image) => onImageSelected(null, image),
        ),
      ],
    );
  }

  static Widget _buildNumberField(ValueSetter<String?> onSaved) {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'Número'),
      onSaved: onSaved,
      keyboardType: TextInputType.number,
    );
  }

  static Widget _buildReceiptField(ValueSetter<String?> onSaved) {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'N° Comprobante'),
      onSaved: onSaved,
      keyboardType: TextInputType.number,
    );
  }
}
