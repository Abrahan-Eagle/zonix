import 'package:flutter/material.dart';
import 'package:zonix/features/GasTicket/gas_button/models/gas_ticket.dart';
import 'package:zonix/features/GasTicket/gas_button/widgets/custom_gas_ticket_item.dart';
import 'package:zonix/features/GasTicket/gas_button/screens/gas_ticket_detail_screen.dart';

class TicketListView extends StatefulWidget {
  final List<GasTicket> tickets;

  const TicketListView({super.key, required this.tickets});

  @override
  TicketListViewState createState() => TicketListViewState();
}

class TicketListViewState extends State<TicketListView> with TickerProviderStateMixin {
  late AnimationController _drawerSlideController;
  late AnimationController _staggeredController;

  GasTicket? _selectedTicket;

  @override
  void initState() {
    super.initState();
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
    return Stack(
      children: [
        ListView.builder(
          itemCount: widget.tickets.length,
          itemBuilder: (context, index) {
            final ticket = widget.tickets[index];
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
        ),
        TicketDetailsDrawer(
          controller: _drawerSlideController,
          selectedTicket: _selectedTicket,
          staggeredController: _staggeredController,
        ),
      ],
    );
  }
}
