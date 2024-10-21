import 'package:flutter/material.dart';
import 'package:zonix/features/GasTicket/gas_button/models/gas_ticket.dart';
import 'package:zonix/features/GasTicket/gas_button/providers/status_provider.dart';

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
  _TicketDetailsDrawerState createState() => _TicketDetailsDrawerState();
}

class _TicketDetailsDrawerState extends State<TicketDetailsDrawer> {
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, ticket),
              const SizedBox(height: 16),
              ..._buildTicketDetailsItems(ticket),
            ],
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

  List<Widget> _buildTicketDetailsItems(GasTicket ticket) {
    final ticketDetails = [
      'Ticket #: ${ticket.id}',
      'Cita: ${ticket.appointmentDate}',
      'Posición de tiempo: ${ticket.timePosition}',
    ];

    return ticketDetails.map((detail) {
      return AnimatedBuilder(
        animation: widget.staggeredController,
        builder: (context, child) {
          final opacity = (widget.staggeredController.value - 0.1).clamp(0.0, 1.0);
          return Opacity(
            opacity: opacity,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                detail,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          );
        },
      );
    }).toList();
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
