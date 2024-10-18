import 'package:flutter/material.dart';
import 'package:zonix/features/GasTicket/api/gas_ticket_service.dart';
import 'package:zonix/features/GasTicket/models/gas_ticket.dart';
import 'package:zonix/features/GasTicket/widgets/custom_gas_ticket_item.dart';

class GasTicketListScreen extends StatefulWidget {
  const GasTicketListScreen({super.key});

  @override
  GasTicketListScreenState createState() => GasTicketListScreenState();
}

class GasTicketListScreenState extends State<GasTicketListScreen>
    with TickerProviderStateMixin {
  final GasTicketService _ticketService = GasTicketService();
  late Future<List<GasTicket>> _ticketListFuture;
  late AnimationController _drawerSlideController;
  late AnimationController _staggeredController;

  static const staggerTime = Duration(milliseconds: 50);

  GasTicket? _selectedTicket;

  @override
  void initState() {
    super.initState();
    _ticketListFuture = _ticketService.fetchGasTickets();
    _drawerSlideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _staggeredController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _drawerSlideController.dispose();
    _staggeredController.dispose();
    super.dispose();
  }

  void _toggleDrawer() {
    _drawerSlideController.isCompleted
        ? _drawerSlideController.reverse()
        : _drawerSlideController.forward();
  }

  void _showTicketDetails(GasTicket ticket) {
    _toggleDrawer();
    setState(() {
      _selectedTicket = ticket;
    });
    _staggeredController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gas Ticket')),
      body: Stack(
        children: [
          FutureBuilder<List<GasTicket>>(
            future: _ticketListFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                final tickets = snapshot.data!;
                return ListView.builder(
                  itemCount: tickets.length,
                  itemBuilder: (context, index) {
                    final ticket = tickets[index];
                    return GestureDetector(
                      onTap: () => _showTicketDetails(ticket),
                      child: CustomGasTicketItem(
                        thumbnail: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        id: ticket.id.toString(),
                        status: ticket.status,
                        appointmentDate: ticket.appointmentDate,
                        timePosition: ticket.timePosition,
                      ),
                    );
                  },
                );
              } else {
                return const Center(child: Text('No tickets available.'));
              }
            },
          ),
          _buildDrawer(),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return AnimatedBuilder(
      animation: _drawerSlideController,
      builder: (context, child) {
        return Transform.scale(
          scale: _drawerSlideController.value,
          alignment: Alignment.centerRight,
          child: _drawerSlideController.isDismissed
              ? const SizedBox()
              : _buildTicketDetails(_selectedTicket),
        );
      },
    );
  }

  Widget _buildTicketDetails(GasTicket? ticket) {
    if (ticket == null) return const SizedBox();

    return Container(
      color: Theme.of(context).colorScheme.background,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        children: [
          _buildFlutterLogo(ticket.status),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(ticket),
              const SizedBox(height: 16),
              ..._buildTicketDetailsItems(ticket),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(GasTicket ticket) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: AnimatedBuilder(
            animation: _staggeredController,
            builder: (context, child) {
              final opacity = (_staggeredController.value - 0.1).clamp(0.0, 1.0);
              return Opacity(
                opacity: opacity,
                child: Text(
                  getStatusSpanish(ticket.status),
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: getStatusColor(ticket.status),
                  ),
                ),
              );
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, size: 30),
          onPressed: _toggleDrawer,
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
        animation: _staggeredController,
        builder: (context, child) {
          final opacity = (_staggeredController.value - 0.1).clamp(0.0, 1.0);
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
          color: getStatusColor(status),
        ),
      ),
    );
  }

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

  String getStatusSpanish(String status) {
    switch (status) {
      case 'pending':
        return 'PENDIENTE';
      case 'verifying':
        return 'VERIFICANDO';
      case 'waiting':
        return 'ESPERANDO';
      case 'dispatched':
        return 'DESPACHADO';
      case 'canceled':
        return 'CANCELADO';
      case 'expired':
        return 'EXPIRADO';
      default:
        return 'ESTADO DESCONOCIDO';
    }
  }
}
