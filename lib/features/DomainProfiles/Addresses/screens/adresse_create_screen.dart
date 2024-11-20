import 'package:flutter/material.dart';
import '../models/adresse.dart';
import '../models/models.dart';
import '../api/adresse_service.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'location_module.dart'; // Importa el módulo de ubicación
import 'package:geolocator/geolocator.dart'; // Importa la clase Position
import 'package:zonix/features/utils/user_provider.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

final logger = Logger();
class RegisterAddressScreen extends StatefulWidget {
  final int userId;

  const RegisterAddressScreen({super.key, required this.userId});

  @override
  RegisterAddressScreenState createState() => RegisterAddressScreenState();
}

class RegisterAddressScreenState extends State<RegisterAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _houseNumberController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final AddressService _addressService = AddressService();
  final LocationModule _locationModule = LocationModule();

  List<Country> countries = [];
  List<StateModel> states = [];
  List<City> cities = [];
  Country? selectedCountry;
  StateModel? selectedState;
  City? selectedCity;

  double? latitude;
  double? longitude;

  @override
  void initState() {
    super.initState();
    logger.i('Console log para verificar el userId al inicio...... Recibiendo userId: ${widget.userId}'); // Console log para verificar el userId al inicio
    loadCountries();
    _captureLocation(); // Captura la ubicación automáticamente al iniciar
  }

  @override
  void dispose() {
    _streetController.dispose();
    _houseNumberController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  Future<void> loadCountries() async {
    try {
      final data = await _addressService.fetchCountries();
      setState(() {
        countries = data;
      });
    } catch (e) {
      _showError('Error al cargar países: $e');
    }
  }

  Future<void> loadStates(int countryId) async {
    try {
      final data = await _addressService.fetchStates(countryId);
      setState(() {
        states = data;
        selectedState = null;
        selectedCity = null;
        cities.clear();
      });
    } catch (e) {
      _showError('Error al cargar estados: $e');
    }
  }

  Future<void> loadCities(int stateId) async {
    try {
      final data = await _addressService.fetchCitiesByState(stateId);
      setState(() {
        cities = data;
        selectedCity = null;
      });
    } catch (e) {
      _showError('Error al cargar ciudades: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _captureLocation() async {
    Position? position = await _locationModule.getCurrentLocation(context);
    if (position != null) {
      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
      });
    } else {
      _showError('No se pudo capturar la ubicación.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Registrar Dirección'),
      // ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Registra tu nueva dirección aquí:',
              style: TextStyle(fontSize: 22),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16.0),
            SvgPicture.asset(
              'assets/images/undraw_mention_re_k5xc.svg',
              height: MediaQuery.of(context).size.height * 0.2,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24.0),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildCountryDropdown(),
                  const SizedBox(height: 16.0),
                  if (selectedCountry != null) _buildStateDropdown(),
                  const SizedBox(height: 16.0),
                  if (selectedState != null) _buildCityDropdown(),
                  const SizedBox(height: 16.0),
                  _buildTextField(_streetController, 'Dirección', 'Por favor ingresa la Dirección'),
                  const SizedBox(height: 16.0),
                  _buildTextField(_houseNumberController, 'N° casa', 'Por favor ingresa el número de la casa'),
                  const SizedBox(height: 16.0),
                  _buildPostalCodeField(),
                  const SizedBox(height: 200.0),
                  ElevatedButton.icon(
                    onPressed: _createAddress,
                    icon: const Icon(Icons.add_location_alt),
                    label: const Text('Registrar Dirección'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  DropdownButtonFormField<Country> _buildCountryDropdown() {
    return DropdownButtonFormField<Country>(
      hint: const Text('Selecciona el país'),
      value: selectedCountry,
      items: countries.map((country) {
        return DropdownMenuItem(
          value: country,
          child: Text(country.name),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedCountry = value;
          selectedState = null;
          selectedCity = null;
          states.clear();
          cities.clear();
        });
        if (value != null) {
          loadStates(value.id);
        }
      },
      validator: (value) => value == null ? 'Por favor selecciona el país' : null,
    );
  }

  DropdownButtonFormField<StateModel> _buildStateDropdown() {
    return DropdownButtonFormField<StateModel>(
      hint: const Text('Selecciona el estado'),
      value: selectedState,
      items: states.map((state) {
        return DropdownMenuItem(
          value: state,
          child: Text(state.name),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedState = value;
          selectedCity = null;
          cities.clear();
        });
        if (value != null) {
          loadCities(value.id);
        }
      },
      validator: (value) => value == null ? 'Por favor selecciona el estado' : null,
    );
  }

  DropdownButtonFormField<City> _buildCityDropdown() {
    return DropdownButtonFormField<City>(
      hint: const Text('Selecciona la ciudad'),
      value: selectedCity,
      items: cities.map((city) {
        return DropdownMenuItem(
          value: city,
          child: Text(city.name),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedCity = value;
        });
      },
      validator: (value) => value == null ? 'Por favor selecciona la ciudad' : null,
    );
  }

  TextFormField _buildPostalCodeField() {
    return TextFormField(
      controller: _postalCodeController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: 'Cód. Postal',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresa el código postal';
        }
        return null;
      },
    );
  }

  TextFormField _buildTextField(TextEditingController controller, String label, String errorMessage) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return errorMessage;
        }
        return null;
      },
    );
  }

  Future<void> _createAddress() async {
    if (_formKey.currentState!.validate() && selectedCity != null) {
      double lat = latitude ?? 0.0;
      double lon = longitude ?? 0.0;
      String status = "activo";
      
      
      logger.i('Transformando userId (${widget.userId}) a profileId'); // Console log antes de usar profileId
      final address = Address(
        id: 0,
        profileId: widget.userId,
        street: _streetController.text,
        houseNumber: _houseNumberController.text,
        cityId: selectedCity!.id,
        postalCode: _postalCodeController.text,
        latitude: lat,
        longitude: lon,
        status: status,
      );

      try {
        await _addressService.createAddress(address, widget.userId);
        
        
        if (mounted) { // Verifica si el widget aún está montado
          Provider.of<UserProvider>(context, listen: false).setAdresseCreated(true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dirección registrada exitosamente')),
          );
          Navigator.of(context).pop();
        }

      } catch (e) {
        _showError('Error registrando la dirección: $e');
      }
    } else {
      _showError('Por favor completa todos los campos requeridos.');
    }
  }
}
