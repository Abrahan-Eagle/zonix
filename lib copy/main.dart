import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:logger/logger.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zonix/features/services/auth/api_service.dart';
import 'package:zonix/features/services/auth/google_sign_in_service.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:zonix/features/utils/auth_utils.dart';
import 'package:google_sign_in/google_sign_in.dart';

const FlutterSecureStorage _storage = FlutterSecureStorage();
final ApiService _apiService = ApiService();

// Configuración del logger
final logger = Logger();

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  initialization(); // Lógica de inicialización.
  runApp(const MyApp());
}

void initialization() async {
  logger.i('ready in 3...');
  await Future.delayed(const Duration(seconds: 1));
  logger.i('ready in 2...');
  await Future.delayed(const Duration(seconds: 1));
  logger.i('ready in 1...');
  await Future.delayed(const Duration(seconds: 1));
  logger.i('go!');
  FlutterNativeSplash
      .remove(); // Remueve el splash screen después de la inicialización.
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZONIX',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: FutureBuilder<bool>(
        // future: _isAuthenticated(),
        future: AuthUtils.isAuthenticated(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.data == true) {
            return const MainRouter(); // Usuario autenticado
          } else {
            return const SignInScreen(); // Usuario no autenticado
          }
        },
      ),
    );
  }
}

class MainRouter extends StatefulWidget {
  const MainRouter({super.key});

  @override
  MainRouterState createState() => MainRouterState();
}

class MainRouterState extends State<MainRouter> {
  int _selectedLevel = 0;
  int _bottomNavIndex = 0;
  bool isFabExpanded = false;

  // Obtiene detalles del usuario autenticado
  Future<Map<String, dynamic>> _getUserDetails() async {
    final token = await _storage.read(key: 'token');
    final response = await http.get(
      Uri.parse('http://192.168.0.102:8000/api/auth/user'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final userDetails = jsonDecode(response.body);
      final role = await _storage.read(key: 'role'); // Obtén el rol aquí
      return {
        'user': userDetails,
        'role': role,
      };
    } else {
      logger.e('Error: ${response.statusCode}');
      throw Exception('Error al obtener detalles del usuario');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadLastPosition(); // Carga la última posición al iniciar.
  }

  // Carga la última posición del nivel y el índice del BottomNavigationBar
  Future<void> _loadLastPosition() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLevel = prefs.getInt('selectedLevel') ?? 0;
      _bottomNavIndex = prefs.getInt('bottomNavIndex') ?? 0;
    });
  }

  // Guarda la última posición del nivel y el índice del BottomNavigationBar
  Future<void> _saveLastPosition() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedLevel', _selectedLevel);
    await prefs.setInt('bottomNavIndex', _bottomNavIndex);
  }

  // Método que determina los botones del BottomNavigationBar según el nivel
  List<BottomNavigationBarItem> _getBottomNavItems(int level) {
    switch (level) {
      case 0:
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.help), label: 'a'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Configuración'),
        ];
      case 1:
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.money), label: 'Finanzas'),
          BottomNavigationBarItem(icon: Icon(Icons.help), label: 'b'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Configuración'),
        ];
      case 2:
        return const [
          BottomNavigationBarItem(
              icon: Icon(Icons.business), label: 'Negocios'),
          BottomNavigationBarItem(icon: Icon(Icons.help), label: 'c'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Configuración'),
        ];
      // Agrega más casos según sea necesario
      default:
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.help), label: 'd'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Configuración'),
        ];
    }
  }

  void _onLevelSelected(int level) {
    setState(() {
      _selectedLevel = level;
      _bottomNavIndex = 0;
      isFabExpanded = false;
      _saveLastPosition();
    });
  }

  void _onBottomNavTapped(int index) {
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                const SignInScreen()), // Navega a la pantalla de perfil
      );
    } else {
      setState(() {
        _bottomNavIndex = index;
        _saveLastPosition();
      });
    }
  }

  // Crea un botón de nivel
  Widget _createLevelButton(int level, IconData icon, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: FloatingActionButton.small(
        heroTag: 'level$level',
        backgroundColor: _selectedLevel == level
            ? Colors.blueAccent[700]
            : Colors.blueAccent[50],
        child: Icon(icon,
            color: _selectedLevel == level ? Colors.white : Colors.black),
        onPressed: () => _onLevelSelected(level),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 4.0,
          title: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'ZONI',
                  style: TextStyle(
                    fontFamily: 'system-ui',
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                    letterSpacing: 1.2,
                  ),
                ),
                TextSpan(
                  text: 'X',
                  style: TextStyle(
                    fontFamily: 'system-ui',
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.blueAccent[700]
                        : Colors.orange,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          centerTitle: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await _handleLogout(); // Llama a la función de logout
              },
            ),
          ]),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _getUserDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final userData =
                snapshot.data!; // Usa todos los datos de la respuesta
            final user = userData['user']; // Accede al objeto user
            final role =
                user['role'] ?? 'guest'; // Obtener el rol del objeto user

            // Aquí puedes usar la variable user si necesitas acceder a más datos
            logger.i(
                'User details: $user'); // Imprime todos los datos del usuario
            logger.i('Role: $role'); // Imprime el rol del usuario

            // Mostrar el nivel y botones del BottomNavigationBar según el rol del usuario
            return Column(
              children: [
                // Mostrar el nivel
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Nivel: $_selectedLevel',
                      style: const TextStyle(fontSize: 24)),
                ),
                // Mostrar la página según el rol del usuario
                Expanded(
                  child: Center(
                    child: (() {
                      switch (role) {
                        case 'admin':
                          return const AdminPage(); // Implementa AdminPage
                        case 'customer':
                          return const CustomerPage(); // Implementa CustomerPage
                        case 'guest':
                          return const GuestPage(); // Implementa GuestPage
                        default:
                          return const Center(child: Text('Rol desconocido'));
                      }
                    }()),
                  ),
                ),
              ],
            );
          }
        },
      ),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        distance: 70.0,
        type: ExpandableFabType.up,
        children: [
          _createLevelButton(0, Icons.propane_tank, 'GAS'),
          _createLevelButton(1, Icons.attach_money, 'Dólares Compra/Venta'),
          _createLevelButton(2, Icons.local_police, '911'),
          _createLevelButton(3, Icons.fastfood, 'Comida Rápida'),
          _createLevelButton(4, Icons.store, 'Tiendas'),
          _createLevelButton(5, Icons.local_taxi, 'Taxis'),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: _getBottomNavItems(
            _selectedLevel), // Obtener los botones según el nivel
        currentIndex: _bottomNavIndex,
        onTap: _onBottomNavTapped,
      ),
    );
  }

   Future<void> _handleLogout() async {
    try {
      final token = await _storage.read(key: 'token');
      if (token != null) {
        final response = await _apiService.logout(token);
        if (response.statusCode == 200) {
          // Elimina todos los datos
          await _storage.deleteAll();

          if (!mounted) return;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SignInScreen()),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sesión cerrada correctamente')),
          );
        } else {
          logger.e('Error: ${response.statusCode}');
          throw Exception('Error en la API al cerrar sesión');
        }
      }
    } catch (e) {
      logger.e('Error al cerrar sesión: $e');
    }
  }
}

// Ejemplos de páginas para los roles de usuario
class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Página del administrador'));
  }
}

class CustomerPage extends StatelessWidget {
  const CustomerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Página del cliente'));
  }
}

class GuestPage extends StatelessWidget {
  const GuestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Página del invitado'));
  }
}

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  SignInScreenState createState() => SignInScreenState();
}



class SignInScreenState extends State<SignInScreen> {
  final GoogleSignInService googleSignInService = GoogleSignInService();
  bool isAuthenticated = false;
  GoogleSignInAccount? _currentUser;
 
 
  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    isAuthenticated = await AuthUtils.isAuthenticated();
    if (isAuthenticated) {
      _currentUser = await GoogleSignInService.getCurrentUser(); // Asegúrate de que este método devuelva un objeto de tipo GoogleUser
    }
    setState(() {});
  }

  Future<void> _handleSignIn() async {
    await GoogleSignInService.signInWithGoogle();
    _currentUser = await GoogleSignInService.getCurrentUser();
    setState(() {});

    if (_currentUser != null) {
      logger.i('Inicio de sesión exitoso');
      logger.i('Usuario: ${_currentUser!.displayName}, Correo: ${_currentUser!.email}');
      
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainRouter()),
      );  
    } else {
      logger.i('Inicio de sesión cancelado o fallido');
    }
  }

  Future<void> _handleLogout() async {
    await googleSignInService.signOut();
    await AuthUtils.logout();
    setState(() {
      _currentUser = null; // Restablece el usuario actual a null
    });

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignInScreen()),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sesión cerrada correctamente')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Google Sign-In')),
      // backgroundColor: Colors.blueGrey,
        //  backgroundColor: Theme.of(context).brightness == Brightness.dark
        //                 ? Colors.blueAccent[700]
        //                 : Colors.orange,
      body: Center(
        child: _currentUser == null ? _buildSignInButton() : _buildUserInfo(),
      ),
    );
  }

  // Widget para mostrar información del usuario
  Widget _buildUserInfo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CircleAvatar(
          backgroundImage: NetworkImage(_currentUser!.photoUrl ?? ''),
          radius: 50,
        ),
        const SizedBox(height: 16),
        Text(
          'Nombre: ${_currentUser!.displayName}',
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 8),
        Text(
          'Correo: ${_currentUser!.email}',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _handleLogout,
          child: const Text('Cerrar sesión'),
        ),
      ],
    );
  }

  // Botón de inicio de sesión
  Widget _buildSignInButton() {
    return ElevatedButton(
      onPressed: _handleSignIn,
      child: const Text('Iniciar sesión con Google'),
    );
  }
}
