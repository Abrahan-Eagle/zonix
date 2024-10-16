import 'package:flutter/material.dart';
import 'package:zonix/features/GasTicket/api/gas_ticket_service.dart';
import 'package:zonix/features/GasTicket/models/gas_ticket.dart'; // Importa GasTicket
import 'package:zonix/features/GasTicket/screens/gas_ticket_detail_screen.dart';
import 'package:zonix/features/GasTicket/widgets/custom_gas_ticket_item.dart'; // Asegúrate de tener un widget personalizado

class GasTicketListScreen extends StatefulWidget {
  const GasTicketListScreen({super.key});

  @override
  GasTicketListScreenState createState() => GasTicketListScreenState();
}

class GasTicketListScreenState extends State<GasTicketListScreen> {
  final GasTicketService _ticketService = GasTicketService();
  late Future<List<GasTicket>> _ticketListFuture;

  @override
  void initState() {
    super.initState();
    _ticketListFuture = _ticketService.fetchGasTickets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gas Ticket'),
      ),
      body: FutureBuilder<List<GasTicket>>(
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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GasTicketDetailScreen(ticket: ticket),
                      ),
                    );
                  },
                  child: CustomGasTicketItem(
                    id: ticket.id.toString(),
                    status: ticket.status,
                    appointmentDate: ticket.appointmentDate,
                    timePosition: ticket.timePosition,
                    // Puedes agregar más campos según necesites
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No tickets available.'));
          }
        },
      ),
    );
  }
}
