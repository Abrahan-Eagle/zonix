import 'package:flutter/material.dart';
import 'package:zonix/features/GasTicket/models/gas_ticket.dart'; // Asegúrate de importar GasTicket

class GasTicketDetailScreen extends StatelessWidget {
  final GasTicket ticket;

  const GasTicketDetailScreen({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ticket #${ticket.id}'),
      ),
      body: Center(
        child: Text('Detalles del ticket: ${ticket.status}'),
      ),
    );
  }
}
