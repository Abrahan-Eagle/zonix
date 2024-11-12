import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Importa flutter_svg
import 'package:http/http.dart' as http;
import 'package:zonix/features/GasTicket/gas_button/api/gas_ticket_service.dart';

class CreateGasTicketScreen extends StatefulWidget {
  final int userId;

  const CreateGasTicketScreen({super.key, required this.userId});

  @override
  CreateGasTicketScreenState createState() => CreateGasTicketScreenState();
}

class CreateGasTicketScreenState extends State<CreateGasTicketScreen> {
  final GasTicketService _ticketService = GasTicketService();
  final _formKey = GlobalKey<FormState>();

  int? _selectedCylinderId;
  List<Map<String, dynamic>> _gasCylinders = [];

  @override
  void initState() {
    super.initState();
    _loadGasCylinders(); // Cargar bombonas al iniciar la pantalla
  }

  Future<void> _loadGasCylinders() async {
    try {
      final cylinders = await _ticketService.fetchGasCylinders(widget.userId);
      setState(() {
        _gasCylinders = cylinders;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading cylinders: $e')),
      );
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _ticketService.createGasTicket(widget.userId, _selectedCylinderId!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ticket created successfully!')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create ticket: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generar Ticket de Gas')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen SVG
              Center(
                child: SvgPicture.asset(
                  'assets/images/undraw_date_picker_re_r0p8.svg',
                  height: 200,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '¡Listo para comprar gas sin complicaciones?\n'
                'Solo elige tu bombona y te daremos una cita con fecha y hora para recogerla. '
                'Sin filas ni demoras, ¡todo más fácil!\n\n'
                '⏳ Ojo: Tu ticket es válido solo por un día, así que asegúrate de ir a tiempo. '
                '¿No puedes asistir? No pasa nada, cancela y reprograma cuando quieras.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Selector de bombonas
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Selecciona una bombona'),
                value: _selectedCylinderId,
                items: _gasCylinders.map((cylinder) {
                  return DropdownMenuItem<int>(
                    value: cylinder['id'],
                    child: Text(cylinder['gas_cylinder_code']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCylinderId = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Por favor, selecciona una bombona' : null,
              ),
              const SizedBox(height: 24),
              
              // Botón de enviar
              Center(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Crear Ticket'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
