// lib/features/GasTicket/widgets/custom_gas_ticket_item.dart

import 'package:flutter/material.dart';

class CustomGasTicketItem extends StatelessWidget {
  final String id;
  final String status;
  final String appointmentDate;
  final String timePosition;

  const CustomGasTicketItem({
    super.key,
    required this.id,
    required this.status,
    required this.appointmentDate,
    required this.timePosition,
  });

  @override
  Widget build(BuildContext context) {
    // Obtén el color de fondo del tema
    final backgroundColor = Theme.of(context).cardColor;
    // Obtén el color del texto
    final textColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;

    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: backgroundColor, // Cambia a un color dinámico según el tema
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3), // Cambia la posición de la sombra
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ticket #$id', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 4),
          Text('Estado: $status', style: TextStyle(color: textColor)),
          Text('Cita: $appointmentDate', style: TextStyle(color: textColor)),
          Text('Posición de tiempo: $timePosition', style: TextStyle(color: textColor)),
        ],
      ),
    );
  }
}
