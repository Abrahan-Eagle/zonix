import 'package:flutter/material.dart';
import 'package:zonix/features/DomainProfiles/GasCylinder/api/gas_cylinder_service.dart';
import 'package:zonix/features/DomainProfiles/GasCylinder/models/gas_cylinder.dart';
import 'package:zonix/features/DomainProfiles/GasCylinder/screens/create_gas_cylinder_screen.dart';

// Pantalla que muestra la lista de bombonas de gas
class GasCylinderListScreen extends StatefulWidget {
  final int userId;

  const GasCylinderListScreen({super.key, required this.userId});

  @override
  State<GasCylinderListScreen> createState() => _GasCylinderListScreenState();
}

class _GasCylinderListScreenState extends State<GasCylinderListScreen> {
  final GasCylinderService _cylinderService = GasCylinderService();
  List<GasCylinder>? _cylinderList;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCylinders(widget.userId);
    });
  }

  Future<void> _loadCylinders(int userId) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final cylinders = await _cylinderService.fetchGasCylinders(userId);
      if (!mounted) return;
      setState(() {
        _cylinderList = cylinders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'No tienes Bombonas Cargada.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bombonas de Gas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _navigateToCreateCylinder(context);
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _cylinderList!.isEmpty
                  ? const Center(child: Text('No hay bombonas disponibles.'))
                  : ListView.builder(
                      itemCount: _cylinderList!.length,
                      itemBuilder: (context, index) {
                        final cylinder = _cylinderList![index];
                        return ListTile(
                          leading: Icon(
                            cylinder.approved ? Icons.check_circle : Icons.cancel,
                            color: cylinder.approved ? Colors.green : Colors.red,
                          ),
                          title: Text(cylinder.gasCylinderCode),
                          subtitle: Text(
                              'Cantidad: ${cylinder.cylinderQuantity ?? 'N/A'}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              // Navegar a la pantalla de edición (opcional)
                            },
                          ),
                        );
                      },
                    ),
    );
  }

  void _navigateToCreateCylinder(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateGasCylinderScreen(userId: widget.userId),
      ),
    );
  }
}

// // Pantalla de creación de una nueva bombona
// class CreateGasCylinderScreen extends StatelessWidget {
//   final int userId;

//   const CreateGasCylinderScreen({super.key, required this.userId});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Crear Bombona'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: GasCylinderForm(userId: userId),
//       ),
//     );
//   }
// }

// // Formulario para crear una nueva bombona
// class GasCylinderForm extends StatefulWidget {
//   final int userId;

//   const GasCylinderForm({super.key, required this.userId});

//   @override
//   State<GasCylinderForm> createState() => _GasCylinderFormState();
// }

// class _GasCylinderFormState extends State<GasCylinderForm> {
//   final _formKey = GlobalKey<FormState>();
//   final _codeController = TextEditingController();
//   final _quantityController = TextEditingController();
//   bool _approved = false;

//   final GasCylinderService _cylinderService = GasCylinderService();

//   @override
//   void dispose() {
//     _codeController.dispose();
//     _quantityController.dispose();
//     super.dispose();
//   }

//   Future<void> _submitForm() async {
//     if (!_formKey.currentState!.validate()) return;

//     final cylinder = GasCylinder(
//       gasCylinderCode: _codeController.text,
//       cylinderQuantity: int.tryParse(_quantityController.text),
//       approved: _approved,
//       profileId: widget.userId,
//     );

//     try {
//       await _cylinderService.createGasCylinder(cylinder, widget.userId);
//       if (!mounted) return;
//       Navigator.pop(context);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error al crear la bombona: $e')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Form(
//       key: _formKey,
//       child: ListView(
//         children: [
//           TextFormField(
//             controller: _codeController,
//             decoration: const InputDecoration(labelText: 'Código de Bombona'),
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Por favor ingresa un código';
//               }
//               return null;
//             },
//           ),
//           TextFormField(
//             controller: _quantityController,
//             decoration: const InputDecoration(labelText: 'Cantidad'),
//             keyboardType: TextInputType.number,
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Por favor ingresa una cantidad';
//               }
//               if (int.tryParse(value) == null) {
//                 return 'Por favor ingresa un número válido';
//               }
//               return null;
//             },
//           ),
//           SwitchListTile(
//             title: const Text('Aprobada'),
//             value: _approved,
//             onChanged: (value) {
//               setState(() {
//                 _approved = value;
//               });
//             },
//           ),
//           ElevatedButton(
//             onPressed: _submitForm,
//             child: const Text('Crear Bombona'),
//           ),
//         ],
//       ),
//     );
//   }
// }
