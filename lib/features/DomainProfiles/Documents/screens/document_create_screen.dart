// screens/create_document_screen.dart
import 'package:flutter/material.dart';
import 'package:zonix/features/DomainProfiles/Documents/api/document_service.dart';

class CreateDocumentScreen extends StatefulWidget {
  final int userId;

  const CreateDocumentScreen({super.key, required this.userId});

  @override
  State<CreateDocumentScreen> createState() => _CreateDocumentScreenState();
}

class _CreateDocumentScreenState extends State<CreateDocumentScreen> {
  final DocumentService _documentService = DocumentService();
  final _formKey = GlobalKey<FormState>();
  // Agrega más variables según los campos del formulario

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar Documento')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Agrega campos para tipo, número, etc.
              ElevatedButton(
                onPressed: () {
                  // Maneja la creación del documento
                },
                child: const Text('Guardarxxxxxxxx'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
