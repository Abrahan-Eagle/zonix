import 'package:flutter/material.dart';
import 'package:zonix/features/DomainProfiles/GasCylinder/models/gas_cylinder.dart';
import 'package:zonix/features/DomainProfiles/GasCylinder/widgets/custom_gas_cylinder_item.dart';
import 'package:zonix/features/DomainProfiles/GasCylinder/screens/gas_cylinder_detail_screen.dart';

class SupplierListView extends StatefulWidget {
  final List<GasSupplier> tickets;

  const SupplierListView({super.key, required this.tickets});

  @override
  SupplierListViewState createState() => SupplierListViewState();
}

class SupplierListViewState extends State<SupplierListView> with TickerProviderStateMixin {
  late AnimationController _drawerSlideController;
  late AnimationController _staggeredController;

  GasSupplier? _selectedTicket;

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

  void _showSupplierDetails(GasSupplier ticket) {
    _toggleDrawer();
    setState(() {
      _selectedTicket = ticket; // Actualiza el ticket seleccionado
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
              onTap: () => _showSupplierDetails(ticket),
              child: CustomGasSupplierItem(
                thumbnail: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                queuePosition: ticket.queuePosition.toString(),
                status: ticket.status,
                appointmentDate: ticket.appointmentDate,
                timePosition: ticket.timePosition,
              ),
            );
          },
        ),
        SupplierDetailsDrawer(
          controller: _drawerSlideController,
          selectedTicket: _selectedTicket, // Se pasa el ticket seleccionado
          staggeredController: _staggeredController,
        ),
      ],
    );
  }
}
