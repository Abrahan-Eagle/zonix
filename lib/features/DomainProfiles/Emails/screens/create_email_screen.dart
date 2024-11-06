import 'package:flutter/material.dart';
import '../models/email.dart';
import '../api/email_service.dart';
import 'package:flutter_svg/flutter_svg.dart'; 
import 'package:zonix/features/utils/user_provider.dart';
import 'package:provider/provider.dart';

class CreateEmailScreen extends StatefulWidget {
  final int userId;

  const CreateEmailScreen({super.key, required this.userId});

  @override
  CreateEmailScreenState createState() => CreateEmailScreenState();
}

class CreateEmailScreenState extends State<CreateEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final EmailService _emailService = EmailService();

  @override
  Widget build(BuildContext context) {
    // Obtenemos las dimensiones de la pantalla
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Email'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createEmail,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Registra tu nuevo correo electrónico aquí:',
                      style: TextStyle(fontSize: 24),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16.0),

                    // Imagen SVG responsiva
                    SvgPicture.asset(
                      'assets/images/undraw_mention_re_k5xc.svg',
                      height: size.height * 0.3, // 30% del alto de la pantalla
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 24.0),

                    // Formulario de creación
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa un email';
                              } else if (!value.contains('@')) {
                                return 'Por favor ingresa un email válido que contenga @';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24.0),

                          // Botón de creación con ícono
                          ElevatedButton.icon(
                            onPressed: _createEmail,
                            icon: const Icon(Icons.email_outlined),
                            label: const Text('Registrar Email'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              minimumSize: const Size(double.infinity, 48), // Botón ancho completo
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _createEmail() async {
    if (_formKey.currentState!.validate()) {
      final email = Email(
        id: 0, // Se generará en el backend
        profileId: widget.userId,
        email: _emailController.text,
        isPrimary: true, // Establecer is_primary como true al Registrar
        status: true,
      );

      try {
        await _emailService.createEmail(email, widget.userId);
        context.read<UserProvider>().setEmailCreated(true);
        Navigator.pop(context, true); // Devolver true para indicar éxito
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al Registrar el email: $e')),
        );
      }
    }
  }
}
