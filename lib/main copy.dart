import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:logger/logger.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zonix/features/GasTicket/api/gas_ticket_service.dart';
import 'package:zonix/features/services/auth/api_service.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:zonix/features/utils/user_provider.dart';
import 'package:flutter/services.dart';
import 'package:zonix/features/screens/profile_page.dart';
import 'package:zonix/features/screens/settings_page_2.dart';
import 'package:zonix/features/screens/sign_in_screen.dart';
import 'package:zonix/features/GasTicket/screens/gas_ticket_list_screen.dart';

const FlutterSecureStorage _storage = FlutterSecureStorage();
final ApiService apiService = ApiService();

// Configuración del logger
final logger = Logger();

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  initialization();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

void initialization() async {
  logger.i('Initializing...');
  await Future.delayed(const Duration(seconds: 3));
  FlutterNativeSplash.remove();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Provider.of<UserProvider>(context, listen: false).checkAuthentication();

    return MaterialApp(
      title: 'ZONIX',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          logger.i('isAuthenticated: ${userProvider.isAuthenticated}');
          if (userProvider.isAuthenticated) {
            return const MainRouter();
          } else {
            return const SignInScreen();
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

  @override
  void initState() {
    super.initState();
    _loadLastPosition();
  }

  Future<void> _loadLastPosition() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLevel = prefs.getInt('selectedLevel') ?? 0;
      _bottomNavIndex = prefs.getInt('bottomNavIndex') ?? 0;
      logger.i(
          'Loaded last position - selectedLevel: $_selectedLevel, bottomNavIndex: $_bottomNavIndex');
    });
  }

  Future<void> _saveLastPosition() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedLevel', _selectedLevel);
    await prefs.setInt('bottomNavIndex', _bottomNavIndex);
    logger.i(
        'Saved last position - selectedLevel: $_selectedLevel, bottomNavIndex: $_bottomNavIndex');
  }

  Future<Map<String, dynamic>> _getUserDetails() async {
    final token = await _storage.read(key: 'token');
    logger.i('Retrieved token: $token');
    final response = await http.get(
      Uri.parse('http://192.168.0.102:8000/api/auth/user'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final userDetails = jsonDecode(response.body);
      final role = await _storage.read(key: 'role');
      logger.i('User details: $userDetails');
      logger.i('User role: $role');
      return {'users': userDetails, 'role': role};
    } else {
      logger.e('Error: ${response.statusCode}');
      throw Exception('Error al obtener detalles del usuario');
    }
  }

  List<BottomNavigationBarItem> _getBottomNavItems(int level) {
    switch (level) {
      case 1:
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.help), label: 'Ayuda1'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Configuración'),
        ];
      case 2:
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.help), label: 'Ayuda2'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Configuración'),
        ];
      case 3:
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.help), label: 'Ayuda3'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Configuración'),
        ];
      case 4:
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.help), label: 'Ayuda4'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Configuración'),
        ];
      case 5:
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.help), label: 'Ayuda5'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Configuración'),
        ];
      default:
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.help), label: 'Ayuda0'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Configuración'),
        ];
    }
  }

  void _onLevelSelected(int level) {
    setState(() {
      _selectedLevel = level;
      _bottomNavIndex = 0;
      _saveLastPosition();
    });
  }

  void _onBottomNavTapped(int index) {
    logger.i('Bottom navigation tapped: $index');

    setState(() {
      _bottomNavIndex = index;
      logger.i('Bottom nav index changed to: $_bottomNavIndex');
      _saveLastPosition();
    });

    if (index == 0) {
      // Navega al módulo de tickets desde el nivel de gas
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const GasTicketListScreen(),
        ),
      );
    } else if (index == 2) {
      // Navega a la pantalla de configuración
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SettingsPage2(),
        ),
      );
    }
  }

  Widget _createLevelButton(int level, IconData icon, String tooltip) {
    return FloatingActionButton.small(
      heroTag: 'level$level',
      backgroundColor: _selectedLevel == level
          ? Colors.blueAccent[700]
          : Colors.blueAccent[50],
      child: Icon(icon,
          color: _selectedLevel == level ? Colors.white : Colors.black),
      onPressed: () => _onLevelSelected(level),
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
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              return GestureDetector(
                onTap: () {
                  showMenu(
                    context: context,
                    position: const RelativeRect.fromLTRB(200, 80, 0, 0),
                    items: [
                      PopupMenuItem(
                        child: const Text('Perfil'),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ProfilePage1()),
                        ),
                      ),
                      PopupMenuItem(
                        child: const Text('Configuración'),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SettingsPage2()),
                        ),
                      ),


                      PopupMenuItem(
                        child: const Text('Cerrar sesión'),
                        onTap: () async {
                          // Obtén el token del almacenamiento seguro
                          String? token = await _storage.read(key: 'token'); // Asegúrate de que 'storage' es tu instancia de FlutterSecureStorage

                          if (token != null) {
                            // Llama al método logout con el token
                            final response = await apiService.logout(token);

                            if (response.statusCode == 200) {
                              // Si el logout fue exitoso, elimina el token
                              await _storage.delete(key: 'token');
                              await _storage.delete(key: 'role');
                              
                              // Aquí puedes realizar la navegación a la pantalla de inicio de sesión
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const SignInScreen()),
                              );
                            } else {
                              // Manejo de errores si el logout no fue exitoso
                              logger.e('Error al cerrar sesión: ${response.body}');
                            }
                          } else {
                            // Manejo de error si no se encuentra el token
                            logger.e('No se encontró el token de sesión');
                          }
                        },
                      ),


                      // PopupMenuItem(
                      //   child: const Text('Cerrar sesión'),
                      //   onTap: () async {
                      //      await apiService.logout();
                      //     await _storage.deleteAll();
                      //     userProvider.logout();
                      //     Navigator.pushReplacement(
                      //       context,
                      //       MaterialPageRoute(builder: (context) => const SignInScreen()),
                      //     );
                      //   },
                      // ),
                    ],
                  );
                },
                child: const Icon(Icons.person),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _getUserDetails(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return Text('Welcome, ${snapshot.data!['users']['name']}');
            }
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: _getBottomNavItems(_selectedLevel),
        currentIndex: _bottomNavIndex,
        onTap: _onBottomNavTapped,
      ),
      floatingActionButton: ExpandableFab(
        distance: 70.0,
        children: [
          _createLevelButton(1, Icons.star, 'Nivel 1'),
          _createLevelButton(2, Icons.star, 'Nivel 2'),
          _createLevelButton(3, Icons.star, 'Nivel 3'),
          _createLevelButton(4, Icons.star, 'Nivel 4'),
          _createLevelButton(5, Icons.star, 'Nivel 5'),
        ],
      ),
    );
  }
}
