import 'package:flutter/material.dart';
import 'package:zonix/features/DomainProfiles/Documents/api/document_service.dart';
import 'package:zonix/features/DomainProfiles/Documents/models/document.dart';
import 'package:zonix/features/DomainProfiles/Documents/screens/document_create_screen.dart';

class DocumentListScreen extends StatefulWidget {
  final int userId;

  const DocumentListScreen({super.key, required this.userId});

  @override
  State<DocumentListScreen> createState() => _DocumentListScreenState();
}

class _DocumentListScreenState extends State<DocumentListScreen> {
  final DocumentService _documentService = DocumentService();

  late Future<List<Document>> _documentsFuture;

  @override
  void initState() {
    super.initState();
    _documentsFuture = _documentService.fetchDocuments(widget.userId);
  }

  Future<void> _navigateToCreateDocument(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateDocumentScreen(userId: widget.userId),
      ),
    );
    setState(() {
      _documentsFuture = _documentService.fetchDocuments(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Documentos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToCreateDocument(context),
          ),
        ],
      ),
      body: FutureBuilder<List<Document>>(
        future: _documentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay documentos disponibles.'));
          }

          final documents = snapshot.data!;
          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final document = documents[index];
              return ListTile(
                title: Text(document.type),
                subtitle: Text('Número: ${document.number ?? 'N/A'}'),
                onTap: () {
                  // Navegar a detalles si es necesario
                },
              );
            },
          );
        },
      ),
    );
  }
}
