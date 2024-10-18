import 'package:flutter/material.dart';

class CustomGasTicketItem extends StatelessWidget {
  final Widget thumbnail;
  final String id;
  final String status;
  final String appointmentDate;
  final String timePosition;

  const CustomGasTicketItem({
    super.key,
    required this.thumbnail,
    required this.id,
    required this.status,
    required this.appointmentDate,
    required this.timePosition,
  });

  // Función para obtener el color según el estado
  Color getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.amber;
      case 'verifying':
        return Colors.blueAccent;
      case 'waiting':
        return Colors.purple;
      case 'dispatched':
        return Colors.green;
      case 'canceled':
        return Colors.red;
      case 'expired':
        return Colors.orange;
      default:
        return Colors.black;
    }
  }

  // Función para obtener la imagen según el estado
  AssetImage getStatusIcon(String status) {
    return const AssetImage('assets/images/splash_logo_dark.png');
  }

  // Función para obtener la traducción del estado
  String getStatusSpanish(String status) {
  switch (status) {
    case 'pending':
      return 'PENDIENTE'; // Convertido a mayúsculas
    case 'verifying':
      return 'VERIFICANDO'; // Convertido a mayúsculas
    case 'waiting':
      return 'ESPERANDO'; // Convertido a mayúsculas
    case 'dispatched':
      return 'DESPACHADO'; // Convertido a mayúsculas
    case 'canceled':
      return 'CANCELADO'; // Convertido a mayúsculas
    case 'expired':
      return 'EXPIRADO'; // Convertido a mayúsculas
    default:
      return 'ESTADO DESCONOCIDO'; // Mensaje por defecto en mayúsculas
  }
}

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;

    // Determinar el color para el texto "Estado:"
    Color estadoLabelColor = Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8.0), // Bordes redondeados
          child: SizedBox(
            width: 56.0,
            height: 56.0,
            child: ImageIcon(
              getStatusIcon(status),
              color: getStatusColor(status), // Color según el estado
              size: 56.0,
            ),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ticket #$id',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 4),
            // Usar Row para mantener "Estado:" y el estado traducido en la misma línea
            Row(
              children: [
                Text(
                  'Estado: ', // El label "Estado:" siempre en blanco o negro
                  style: TextStyle(color: estadoLabelColor),
                ),
                Text(
                  getStatusSpanish(status), // Llamada a la función para obtener el estado en español
                  style: TextStyle(color: getStatusColor(status), fontWeight: FontWeight.bold), // Color según el estado
                ),
              ],
            ),
            Text('Cita: $appointmentDate', style: TextStyle(color: textColor)),
            Text('Posición de tiempo: $timePosition', style: TextStyle(color: textColor)),
          ],
        ),
      ),
    );
  }
}
