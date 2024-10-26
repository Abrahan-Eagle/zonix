import 'package:flutter/material.dart';
import '../models/email.dart';
import '../api/email_service.dart';
import '../screens/create_email_screen.dart';

class EmailListScreen extends StatefulWidget {
  final int userId;

  const EmailListScreen({super.key, required this.userId});

  @override
  EmailListScreenState createState() => EmailListScreenState();
}

class EmailListScreenState extends State<EmailListScreen> {
  final EmailService _emailService = EmailService();
  late Future<List<Email>> _emails;

  @override
  void initState() {
    super.initState();
    _emails = _emailService.fetchEmails(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emails'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToCreateEmail, // Acción al presionar el botón
          ),
        ],
      ),
      body: FutureBuilder<List<Email>>(
        future: _emails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay correos disponibles.'));
          } else {
            final emails = snapshot.data!;
            return ListView.builder(
              itemCount: emails.length,
              itemBuilder: (context, index) {
                final email = emails[index];
                return ListTile(
                  title: Text(email.email),
                  subtitle: Text(
                    email.isPrimary ? 'Correo Primario' : 'Correo Secundario',
                  ),
                  trailing: Switch(
                    value: email.isPrimary,
                    onChanged: (value) async {
                      await _emailService.updateEmail(
                        email.id,
                        email.copyWith(isPrimary: value),
                      );
                      setState(() {
                        _emails = _emailService.fetchEmails(widget.userId);
                      });
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  // Navegar a la pantalla de creación de email
  void _navigateToCreateEmail() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateEmailScreen(userId: widget.userId),
      ),
    );

    // Si se creó un email, recargar la lista de emails
    if (result == true) {
      setState(() {
        _emails = _emailService.fetchEmails(widget.userId);
      });
    }
  }
}
