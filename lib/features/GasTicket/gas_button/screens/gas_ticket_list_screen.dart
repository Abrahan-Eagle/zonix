import 'package:flutter/material.dart';
import 'package:zonix/features/GasTicket/gas_button/api/gas_ticket_service.dart';
import 'package:zonix/features/GasTicket/gas_button/models/gas_ticket.dart';
import 'package:zonix/features/GasTicket/gas_button/widgets/ticket_list_view.dart';

class GasTicketListScreen extends StatefulWidget {
  const GasTicketListScreen({super.key});

  @override
  GasTicketListScreenState createState() => GasTicketListScreenState();
}

class GasTicketListScreenState extends State<GasTicketListScreen>
    with TickerProviderStateMixin {
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
    body: Padding(
      padding: const EdgeInsets.only(top: 6.0), // Espacio superior de 50px
      child: FutureBuilder<List<GasTicket>>(
        future: _ticketListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final tickets = snapshot.data!;
            return TicketListView(tickets: tickets);
          } else {
            return const Center(child: Text('No tickets available.'));
          }
        },
      ),
    ),
  );
}


  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     // appBar: AppBar(title: const Text('Gas Ticket')),
  //     body: FutureBuilder<List<GasTicket>>(
  //       future: _ticketListFuture,
  //       builder: (context, snapshot) {
  //         if (snapshot.connectionState == ConnectionState.waiting) {
  //           return const Center(child: CircularProgressIndicator());
  //         } else if (snapshot.hasError) {
  //           return Center(child: Text('Error: ${snapshot.error}'));
  //         } else if (snapshot.hasData) {
  //           final tickets = snapshot.data!;
  //           return TicketListView(tickets: tickets);
  //         } else {
  //           return const Center(child: Text('No tickets available.'));
  //         }
  //       },
  //     ),
  //   );
  // }
}
