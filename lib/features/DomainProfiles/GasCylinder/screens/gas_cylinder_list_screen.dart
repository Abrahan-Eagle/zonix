import 'package:flutter/material.dart';
import 'package:zonix/features/DomainProfiles/GasCylinder/api/gas_cylinder_service.dart';
import 'package:zonix/features/DomainProfiles/GasCylinder/models/gas_cylinder.dart';
import 'package:zonix/features/DomainProfiles/GasCylinder/screens/create_gas_cylinder_screen.dart';
import 'package:zonix/features/DomainProfiles/GasCylinder/screens/gas_cylinder_detail_screen.dart'; // Importar la pantalla de detalles

class GasCylinderListScreen extends StatefulWidget {
  final int userId;

  const GasCylinderListScreen({super.key, required this.userId});

  @override
  State<GasCylinderListScreen> createState() => _GasCylinderListScreenState();
}

class _GasCylinderListScreenState extends State<GasCylinderListScreen> {
  final GasCylinderService _cylinderService = GasCylinderService();

  // Método que carga las bombonas desde la API.
  Future<List<GasCylinder>> _fetchCylinders() async {
    try {
      return await _cylinderService.fetchGasCylinders(widget.userId);
    } catch (e) {
      throw Exception('No tienes Bombonas cargadas.');
    }
  }

  // Navegar a la pantalla de creación de bombonas y recargar al regresar.
  Future<void> _navigateToCreateCylinder(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateGasCylinderScreen(userId: widget.userId),
      ),
    );
    setState(() {}); // Recargar la lista al regresar.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bombonas de Gas'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return FutureBuilder<List<GasCylinder>>(
            future: _fetchCylinders(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text(snapshot.error.toString()));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No hay bombonas disponibles.'));
              }

              final cylinders = snapshot.data!;
              return ListView.builder(
                itemCount: cylinders.length,
                itemBuilder: (context, index) {
                  final cylinder = cylinders[index];
                  return ListTile(
                    leading: Icon(
                      cylinder.approved ? Icons.check_circle : Icons.cancel,
                      color: cylinder.approved ? Colors.green : Colors.red,
                    ),
                    title: Text(cylinder.gasCylinderCode),
                    subtitle: Text(
                      'Cantidad: ${cylinder.cylinderQuantity ?? 'N/A'}',
                    ),
                    onTap: () {
                      // Navegar a la pantalla de detalles al tocar un elemento
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GasCylinderDetailScreen(cylinder: cylinder),
                        ),
                      );
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        // Navegar a la pantalla de edición (opcional)
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateCylinder(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}




// import 'package:flutter/material.dart';
// import 'package:zonix/features/DomainProfiles/GasCylinder/api/gas_cylinder_service.dart';
// import 'package:zonix/features/DomainProfiles/GasCylinder/models/gas_cylinder.dart';
// import 'package:zonix/features/DomainProfiles/GasCylinder/screens/create_gas_cylinder_screen.dart';
// import 'package:zonix/features/DomainProfiles/GasCylinder/screens/gas_cylinder_detail_screen.dart'; // Importar la pantalla de detalles

// class GasCylinderListScreen extends StatefulWidget {
//   final int userId;

//   const GasCylinderListScreen({super.key, required this.userId});

//   @override
//   State<GasCylinderListScreen> createState() => _GasCylinderListScreenState();
// }

// class _GasCylinderListScreenState extends State<GasCylinderListScreen> {
//   final GasCylinderService _cylinderService = GasCylinderService();

//   // Método que carga las bombonas desde la API.
//   Future<List<GasCylinder>> _fetchCylinders() async {
//     try {
//       return await _cylinderService.fetchGasCylinders(widget.userId);
//     } catch (e) {
//       throw Exception('No tienes Bombonas cargadas.');
//     }
//   }

//   // Navegar a la pantalla de creación de bombonas y recargar al regresar.
//   Future<void> _navigateToCreateCylinder(BuildContext context) async {
//     await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => CreateGasCylinderScreen(userId: widget.userId),
//       ),
//     );
//     setState(() {}); // Recargar la lista al regresar.
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Bombonas de Gas'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.add),
//             onPressed: () => _navigateToCreateCylinder(context),
//           ),
//         ],
//       ),
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           return FutureBuilder<List<GasCylinder>>(
//             future: _fetchCylinders(),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               } else if (snapshot.hasError) {
//                 return Center(child: Text(snapshot.error.toString()));
//               } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                 return const Center(child: Text('No hay bombonas disponibles.'));
//               }

//               final cylinders = snapshot.data!;
//               return ListView.builder(
//                 itemCount: cylinders.length,
//                 itemBuilder: (context, index) {
//                   final cylinder = cylinders[index];
//                   return ListTile(
//                     leading: Icon(
//                       cylinder.approved ? Icons.check_circle : Icons.cancel,
//                       color: cylinder.approved ? Colors.green : Colors.red,
//                     ),
//                     title: Text(cylinder.gasCylinderCode),
//                     subtitle: Text(
//                       'Cantidad: ${cylinder.cylinderQuantity ?? 'N/A'}',
//                     ),
//                     onTap: () {
//                       // Navegar a la pantalla de detalles al tocar un elemento
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => GasCylinderDetailScreen(cylinder: cylinder),
//                         ),
//                       );
//                     },
//                     trailing: IconButton(
//                       icon: const Icon(Icons.edit),
//                       onPressed: () {
//                         // Navegar a la pantalla de edición (opcional)
//                       },
//                     ),
//                   );
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

