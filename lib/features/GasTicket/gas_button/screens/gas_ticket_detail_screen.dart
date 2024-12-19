import 'package:flutter/material.dart';
import 'package:zonix/features/GasTicket/gas_button/models/gas_ticket.dart';
import 'package:zonix/features/GasTicket/gas_button/providers/status_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';  // Asegúrate de importar el paquete correcto
import 'package:intl/intl.dart';

class TicketDetailsDrawer extends StatefulWidget {
  final AnimationController controller;
  final GasTicket? selectedTicket;
  final AnimationController staggeredController;

  const TicketDetailsDrawer({
    super.key,
    required this.controller,
    required this.selectedTicket,
    required this.staggeredController,
  });

  @override
  TicketDetailsDrawerState createState() => TicketDetailsDrawerState();
}

class TicketDetailsDrawerState extends State<TicketDetailsDrawer> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.controller.value,
          alignment: Alignment.centerRight,
          child: widget.controller.isDismissed
              ? const SizedBox()
              : _buildTicketDetails(context, widget.selectedTicket),
        );
      },
    );
  }

  Widget _buildTicketDetails(BuildContext context, GasTicket? ticket) {
    if (ticket == null) return const SizedBox();

    return Container(
      color: Theme.of(context).colorScheme.surface,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      padding: const EdgeInsets.all(6.0),
      child: Stack(
        children: [
          _buildFlutterLogo(ticket.status),
          SingleChildScrollView(  // Permite desplazarse si el contenido es largo
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, ticket),
                const SizedBox(height: 16),
                // Código QR colocado encima de los detalles
                _buildQRCode(ticket),
                const SizedBox(height: 16),
                ..._buildTicketDetailsItems(ticket),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, GasTicket ticket) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: AnimatedBuilder(
            animation: widget.staggeredController,
            builder: (context, child) {
              final opacity = (widget.staggeredController.value - 0.1).clamp(0.0, 1.0);
              return Opacity(
                opacity: opacity,
                child: Text(
                  StatusProvider().getStatusSpanish(ticket.status),
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: StatusProvider().getStatusColor(ticket.status),
                  ),
                ),
              );
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, size: 30),
          onPressed: () {
            widget.controller.reverse();
          },
        ),
      ],
    );
  }

  // Colocamos el QR aquí fuera de _buildDetailSection
Widget _buildQRCode(GasTicket ticket) {
  // Obtener el color adecuado según el modo de tema (oscuro o claro)
  Color qrForegroundColor = Theme.of(context).brightness == Brightness.dark
      ? Colors.white  // Color blanco si el tema es oscuro
      : Colors.black;  // Color negro si el tema es claro

  return Center(
    child: QrImageView(
      data: ticket.id.toString(), // El ID del ticket para el QR
      version: QrVersions.auto,  // Establece la versión automáticamente
      size: 300.0,  // Ajusta el tamaño del QR según lo que necesites
      foregroundColor: qrForegroundColor,  // Establece el color del QR según el modo de tema
      backgroundColor: Colors.transparent,  // Fondo transparente para el QR
    ),
  );
}

String _formatDate(String date) {
  try {
    final parsedDate = DateTime.parse(date);  // Convierte el string a DateTime
    final formattedDate = DateFormat('dd/MM/yyyy').format(parsedDate);  // Formatea la fecha
    return formattedDate;
  } catch (e) {
    return date;  // Si no puede parsear la fecha, devuelve el string original
  }
}



  List<Widget> _buildTicketDetailsItems(GasTicket ticket) {
    return [
      _buildDetailSection('Detalles del Ticket', [
        'Ticket #: ${ticket.queuePosition}',
        'Hora asignada: ${ticket.timePosition}',
        'Cita agendada: ${_formatDate(ticket.appointmentDate)}',        
        'Fecha de solicitud: ${_formatDate(ticket.reservedDate)}',  // Formatea la fecha reservada
        'Fecha de expiración: ${_formatDate(ticket.expiryDate)}',  // Formatea la fecha de vencimiento
        'Estado actual: ${StatusProvider().getStatusSpanish(ticket.status)}',
         // 'Estado: ${ticket.status}',
      ]),
      _buildDetailSection('Datos del Usuario', [
        'Solicitante: ${ticket.firstName} ${ticket.lastName}',
        'Teléfono: ${ticket.phoneNumbers}', // Asumiendo que hay al menos un teléfono
        'Dirección: ${ticket.addresses}', // Se asume que hay al menos una dirección
      ]), 

      _buildDetailSection('Información de la Bombona de Gas', [
        'Código de la bombona: ${ticket.gasCylinderCode}',
        'Tipo de bombona: ${ticket.cylinderType}',
        'Peso de la bombona: ${ticket.cylinderWeight}',
        'Foto de la bombona: ${ticket.gasCylinderPhoto}',
      ]),
    ];
  }

Widget _buildDetailSection(String title, List<String> details) {
  return ExpansionTile(
    title: Align(
      alignment: Alignment.centerLeft, // Alinea el título hacia la izquierda
      child: Text(
        title,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    ),
    children: details.map((detail) {
      return Align(
        alignment: Alignment.centerLeft, // Alinea cada detalle hacia la izquierda
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            detail,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      );
    }).toList(),
  );
}

  Widget _buildFlutterLogo(String status) {
    return Positioned(
      right: -100,
      bottom: -30,
      child: Opacity(
        opacity: 0.3,
        child: Image.asset(
          'assets/images/splash_logo_dark.png',
          width: 425,
          height: 425,
          fit: BoxFit.cover,
          color: StatusProvider().getStatusColor(status),
        ),
      ),
    );
  }
}
