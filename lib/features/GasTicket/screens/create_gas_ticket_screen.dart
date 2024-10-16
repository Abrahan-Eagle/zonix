import 'package:flutter/material.dart';
import 'package:zonix/features/GasTicket/api/gas_ticket_service.dart';


class CreateGasTicketScreen extends StatefulWidget {
  const CreateGasTicketScreen({super.key});

  @override
  CreateGasTicketScreenState createState() => CreateGasTicketScreenState();
}

class CreateGasTicketScreenState extends State<CreateGasTicketScreen> {
  final GasTicketService _ticketService = GasTicketService();
  final _formKey = GlobalKey<FormState>();
  int? _profileId;
  int? _cylinderId;

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _ticketService.createGasTicket(_profileId!, _cylinderId!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ticket created successfully!')),
        );
        Navigator.pop(context); // Volver a la lista de tickets
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
      appBar: AppBar(title: const Text('Create Gas Ticket')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Profile ID'),
                keyboardType: TextInputType.number,
                onChanged: (value) => _profileId = int.tryParse(value),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a profile ID';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Cylinder ID'),
                keyboardType: TextInputType.number,
                onChanged: (value) => _cylinderId = int.tryParse(value),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a cylinder ID';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Create Ticket'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
