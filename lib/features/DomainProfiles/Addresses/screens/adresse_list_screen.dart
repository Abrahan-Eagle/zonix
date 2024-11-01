import 'package:flutter/material.dart';
import 'package:zonix/features/DomainProfiles/Addresses/api/adresse_service.dart';
import 'package:zonix/features/DomainProfiles/Addresses/models/adresse.dart';
import 'package:zonix/features/DomainProfiles/Addresses/screens/adresse_create_screen.dart';
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
    final width = MediaQuery.of(context).size.width;
    final isSmallScreen = width < 600;

    return ChangeNotifierProvider(
      create: (_) => AddressModel()..loadAddress(userId),
      child: Consumer<AddressModel>(
        builder: (context, addressModel, child) {
          if (addressModel.isLoading) {
            return Scaffold(
              appBar: AppBar(title: const Text('Dirección')),
              body: const Center(child: CircularProgressIndicator()),
              floatingActionButton: _buildFloatingActionButton(context),
            );
          }

          if (addressModel.address == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Dirección')),
              body: const Center(
                child: Text(
                  'No hay información de dirección disponible.',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              floatingActionButton: _buildFloatingActionButton(context),
            );
          }

          return Scaffold(
            appBar: AppBar(title: const Text('Dirección')),
            body: _buildAddressDetails(addressModel.address!, context, isSmallScreen),
            floatingActionButton: _buildFloatingActionButton(context),
          );
        },
      ),
    );
  }

  FloatingActionButton _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RegisterAddressScreen(userId: userId),
          ),
        );
      },
      child: const Icon(Icons.add),
    );
  }

  Widget _buildAddressDetails(Address address, BuildContext context, bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildField('Dirección', address.street, isTight: true, isSmallScreen: isSmallScreen),
                  _buildField('N° casa', address.houseNumber, isSmallScreen: isSmallScreen),
                  _buildField('Código Postal', address.postalCode, isSmallScreen: isSmallScreen),
                  _buildField('Estado', _translateStatus(address.status), isSmallScreen: isSmallScreen),
                ],
              ),
            ),
          ),
          SizedBox(height: isSmallScreen ? 10 : 20),
          _buildMap(address.latitude, address.longitude, context),
        ],
      ),
    );
  }

  String _translateStatus(String status) {
    switch (status) {
      case 'completeData':
        return 'Datos completos';
      case 'incompleteData':
        return 'Datos incompletos';
      case 'notverified':
        return 'No verificado';
      default:
        return 'Estado desconocido';
    }
  }

  Widget _buildField(String label, String value, {bool isTight = false, required bool isSmallScreen}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 4.0 : 6.0),
      child: Row(
        children: [
          Expanded(
            flex: isTight ? 1 : 2,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isSmallScreen ? 14 : 16,
              ),
            ),
          ),
          Expanded(
            flex: isTight ? 1 : 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap(double latitude, double longitude, BuildContext context) {
    if (latitude < -90 || latitude > 90 || longitude < -180 || longitude > 180) {
      return const Center(child: Text('Coordenadas inválidas.'));
    }

    final width = MediaQuery.of(context).size.width;
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://www.google.com/maps/@$latitude,$longitude,15z'));

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      width: width,
      child: WebViewWidget(controller: controller),
    );
  }
}
