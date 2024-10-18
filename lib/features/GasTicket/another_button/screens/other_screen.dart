import 'package:flutter/material.dart';

class OtherScreen extends StatelessWidget {
  const OtherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Otra Pantalla'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bienvenido a la Otra Pantalla',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Esta es una pantalla de ejemplo que puedes utilizar para mostrar información adicional, '
              'opciones, o cualquier otro contenido que consideres relevante.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Aquí puedes agregar la lógica para cualquier acción que quieras realizar
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Botón presionado!')),
                );
              },
              child: const Text('Presiona aquí'),
            ),
          ],
        ),
      ),
    );
  }
}
