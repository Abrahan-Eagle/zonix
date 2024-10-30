import 'package:flutter/material.dart';
import 'package:zonix/features/DomainProfiles/Addresses/api/adresse_service.dart';
import 'package:zonix/features/DomainProfiles/Addresses/models/adresse.dart';
import 'package:zonix/features/DomainProfiles/Addresses/screens/adresse_create_screen.dart'; // Asegúrate de que la ruta sea correcta
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AddressModel with ChangeNotifier {
  Address? _address;
  bool _isLoading = true;

  Address? get address => _address;
  bool get isLoading => _isLoading;

  Future<void> loadAddress(int userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _address = await AddressService().getAddressById(userId);
    } catch (e) {
      _address = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

class AddressPage extends StatelessWidget {
  final int userId;

  const AddressPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddressModel()..loadAddress(userId),
      child: Consumer<AddressModel>(
        builder: (context, addressModel, child) {
          if (addressModel.isLoading) {
            return Scaffold(
              appBar: AppBar(title: const Text('Dirección')),
              body: const Center(child: CircularProgressIndicator()),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  // Redirigir a la pantalla de creación de dirección
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RegisterAddressScreen(userId: userId),
                    ),
                  );
                },
                child: const Icon(Icons.add),
              ),
            );
          }

          if (addressModel.address == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Dirección')),
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Redirigir a la pantalla de creación de dirección
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegisterAddressScreen(userId: userId),
                      ),
                    );
                  },
                  child: const Text('Crear Dirección'),
                ),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  // Redirigir a la pantalla de creación de dirección
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RegisterAddressScreen(userId: userId),
                    ),
                  );
                },
                child: const Icon(Icons.add),
              ),
            );
          }

          return Scaffold(
            appBar: AppBar(title: const Text('Detalle de Dirección')),
            body: _buildAddressDetails(addressModel.address!, context),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                // Redirigir a la pantalla de creación de dirección
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegisterAddressScreen(userId: userId),
                  ),
                );
              },
              child: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddressDetails(Address address, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildField('Calle', address.street),
          _buildField('Número', address.houseNumber),
          _buildField('Código Postal', address.postalCode),
          _buildField('Latitud', address.latitude.toString()),
          _buildField('Longitud', address.longitude.toString()),
          _buildField('Estado', address.status),
          const SizedBox(height: 20),
          _buildMap(address.latitude, address.longitude, context),
        ],
      ),
    );
  }

  Widget _buildField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value, textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }

  Widget _buildMap(double latitude, double longitude, BuildContext context) {
    if (latitude < -90 || latitude > 90 || longitude < -180 || longitude > 180) {
      return const Center(child: Text('Coordenadas inválidas.'));
    }

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.parse(
          'https://www.google.com/maps/@$latitude,$longitude,15z',
        ),
      );

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      width: MediaQuery.of(context).size.width,
      child: WebViewWidget(controller: controller),
    );
  }
}
