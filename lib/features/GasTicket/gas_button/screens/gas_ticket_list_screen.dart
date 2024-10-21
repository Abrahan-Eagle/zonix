import 'package:flutter/material.dart';
import 'package:zonix/features/GasTicket/gas_button/api/gas_ticket_service.dart';
import 'package:zonix/features/GasTicket/gas_button/models/gas_ticket.dart';
import 'package:zonix/features/GasTicket/gas_button/widgets/ticket_list_view.dart';

class GasTicketListScreen extends StatefulWidget {
  const GasTicketListScreen({super.key});

  @override
  GasTicketListScreenState createState() => GasTicketListScreenState();
}

class GasTicketListScreenState extends State<GasTicketListScreen> with TickerProviderStateMixin {
  final GasTicketService _ticketService = GasTicketService();
  List<GasTicket>? _ticketList;

  @override
  void initState() {
    super.initState();
    _loadTickets(); // Cargar tickets al inicio
  }

  // Método para cargar tickets
  Future<void> _loadTickets() async {
    try {
      final tickets = await _ticketService.fetchGasTickets();
      setState(() {
        _ticketList = tickets; // Actualizar el estado
      });
    } catch (e) {
      // Manejar el error si es necesario
      print('Error al cargar tickets: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 6.0), // Espacio superior de 50px
        child: _ticketList == null
            ? const Center(child: CircularProgressIndicator())
            : _ticketList!.isEmpty
                ? const Center(child: Text('No tickets available.'))
                : TicketListView(tickets: _ticketList!),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Simulación de añadir un nuevo ticket y recargar la lista
          _loadTickets();
        },
        child: const Icon(Icons.refresh), // Icono de refrescar
      ),
    );
  }
}
