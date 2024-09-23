import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:logger/logger.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './features/config/theme.dart';
import 'package:zonix/features/services/auth/api_service.dart';
import 'package:zonix/features/services/auth/google_sign_in_service.dart';
import 'dart:convert';

final logger = Logger();

void main() {
  // Inicializa el binding de widgets y preserva el splash screen.
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  initialization(); // Lógica de inicialización.
  runApp(const MyApp());
}

void initialization() async {
  // Muestra mensajes de carga en la consola.
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
    // Configuración de la aplicación principal.
    return MaterialApp(
      title: 'ZONIX',
      debugShowCheckedModeBanner: false,
      theme: lightTheme, // Tema claro.
      darkTheme: darkTheme, // Tema oscuro.
      themeMode: ThemeMode.system, // Selección automática de tema.
      home: const MainRouter(), // Pantalla principal.
    );
  }
}

class MainRouter extends StatefulWidget {
  const MainRouter({super.key});
  @override
  MainRouterState createState() => MainRouterState();
}

class MainRouterState extends State<MainRouter> {
  int _selectedLevel = 0; // Nivel seleccionado.
  int _bottomNavIndex = 0; // Índice del BottomNavigationBar.
  bool isFabExpanded = false; // Estado del FAB expandido.

  // Lista de niveles.
  final List<Widget> levels = [
    const LevelGas(),
    const LevelDolar(),
    const Level911(),
    const LevelComidaRapida(),
    const LevelTiendas(),
    const LevelTaxi(),
  ];

  // Items del BottomNavigationBar según el nivel, agregando el botón de perfil.
  final List<List<BottomNavigationBarItem>> _bottomNavItems = [
    const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.help), label: 'Ayuda'),
      BottomNavigationBarItem(
          icon: Icon(Icons.person), label: 'Perfil'), // Botón de perfil
    ],
    const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Work'),
      BottomNavigationBarItem(
          icon: Icon(Icons.person), label: 'Perfil'), // Botón de perfil
    ],
    const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.food_bank), label: 'Comida'),
      BottomNavigationBarItem(
          icon: Icon(Icons.person), label: 'Perfil'), // Botón de perfil
    ],
    const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.business), label: 'Business'),
      BottomNavigationBarItem(
          icon: Icon(Icons.person), label: 'Perfil'), // Botón de perfil
    ],
    const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Work'),
      BottomNavigationBarItem(
          icon: Icon(Icons.person), label: 'Perfil'), // Botón de perfil
    ],
    const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.food_bank), label: 'Comida'),
      BottomNavigationBarItem(
          icon: Icon(Icons.person), label: 'Perfil'), // Botón de perfil
    ],
  ];

  // Contenido del BottomNavigationBar según el nivel.
  final List<List<Widget>> _bottomNavContent = [
    const [
      Center(child: Text('Esta es la pantalla de Home')),
      Center(child: Text('Esta es la pantalla de Business')),
      Center(
          child:
              Text('Esta es la pantalla de Perfil')), // Contenido para perfil
    ],
    const [
      Center(child: Text('Esta es la pantalla de Home')),
      Center(child: Text('Esta es la pantalla de Work')),
      Center(
          child:
              Text('Esta es la pantalla de Perfil')), // Contenido para perfil
    ],
    const [
      Center(child: Text('Esta es la pantalla de Home')),
      Center(child: Text('Esta es la pantalla de Comida')),
      Center(
          child:
              Text('Esta es la pantalla de Perfil')), // Contenido para perfil
    ],
    const [
      Center(child: Text('Esta es la pantalla de Home')),
      Center(child: Text('Esta es la pantalla de Business')),
      Center(
          child:
              Text('Esta es la pantalla de Perfil')), // Contenido para perfil
    ],
    const [
      Center(child: Text('Esta es la pantalla de Home')),
      Center(child: Text('Esta es la pantalla de Work')),
      Center(
          child:
              Text('Esta es la pantalla de Perfil')), // Contenido para perfil
    ],
    const [
      Center(child: Text('Esta es la pantalla de Home')),
      Center(child: Text('Esta es la pantalla de Comida')),
      Center(
          child:
              Text('Esta es la pantalla de Perfil')), // Contenido para perfil
    ],
  ];

  @override
  void initState() {
    super.initState();
    _loadLastPosition(); // Carga la última posición al iniciar.
  }

  // Carga la última posición guardada.
  Future<void> _loadLastPosition() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLevel =
          prefs.getInt('selectedLevel') ?? 0; // Carga el nivel seleccionado.
      _bottomNavIndex = prefs.getInt('bottomNavIndex') ??
          0; // Carga el índice del BottomNavigationBar.
    });
  }

  // Guarda la posición actual.
  Future<void> _saveLastPosition() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedLevel', _selectedLevel);
    await prefs.setInt('bottomNavIndex', _bottomNavIndex);
  }

  // Cambia el nivel seleccionado.
  void _onLevelSelected(int level) {
    setState(() {
      _selectedLevel = level; // Actualiza el nivel seleccionado.
      _bottomNavIndex = 0; // Resetea el índice del BottomNavigationBar.
      isFabExpanded = false; // Cierra el ExpandableFab.
      _saveLastPosition(); // Guarda la posición actual.
    });
  }

  // Cambia el índice del BottomNavigationBar.
  void _onBottomNavTapped(int index) {
    if (index == 2) {
      // Índice del botón de perfil
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                const SignInScreen()), // Navega a la pantalla de perfil
      );
    } else {
      setState(() {
        _bottomNavIndex = index; // Actualiza el índice.
        _saveLastPosition(); // Guarda la posición actual.
      });
    }
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
          PopupMenuButton<int>(
            onSelected: (value) {
              // Acciones según el valor seleccionado del menú emergente.
              if (value == 1) {
                // Acción para el botón editar.
              } else if (value == 2) {
                // Acción para el botón compartir.
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 1, child: Text("Editar")),
              const PopupMenuItem(value: 2, child: Text("Compartir")),
            ],
          ),
        ],
      ),
      body: _bottomNavContent[_selectedLevel]
          [_bottomNavIndex], // Cambia dinámicamente el contenido.
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        distance: 70.0,
        type: ExpandableFabType.up,
        children: [
          Tooltip(
            message: 'GAS',
            child: FloatingActionButton.small(
              heroTag: 'levelGas',
              backgroundColor: _selectedLevel == 0
                  ? Colors.blueAccent[700]
                  : Colors
                      .blueAccent[50], // Cambia el color si es el nivel activo
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.propane_tank,
                    color: _selectedLevel == 0
                        ? Colors.white
                        : Colors
                            .black, // Cambia el color del ícono si es el nivel activo
                  ),
                ],
              ),
              onPressed: () {
                _onLevelSelected(0); // Cambia al Nivel Gas.
                setState(() => isFabExpanded = false); // Cierra el FAB.
              },
            ),
          ),
          Tooltip(
            message: 'Dólares Compra/Venta',
            child: FloatingActionButton.small(
              heroTag: 'levelDolar',
              backgroundColor: _selectedLevel == 1
                  ? Colors.blueAccent[700]
                  : Colors
                      .blueAccent[50], // Cambia el color si es el nivel activo
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.currency_exchange,
                    color: _selectedLevel == 1
                        ? Colors.white
                        : Colors
                            .black, // Cambia el color del ícono si es el nivel activo
                  ),
                ],
              ),
              onPressed: () {
                _onLevelSelected(1); // Cambia al Nivel Dólares.
                setState(() => isFabExpanded = false); // Cierra el FAB.
              },
            ),
          ),
          Tooltip(
            message: '911',
            child: FloatingActionButton.small(
              heroTag: 'level911',
              backgroundColor: _selectedLevel == 2
                  ? Colors.blueAccent[700]
                  : Colors
                      .blueAccent[50], // Cambia el color si es el nivel activo
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.local_police,
                    color: _selectedLevel == 2
                        ? Colors.white
                        : Colors
                            .black, // Cambia el color del ícono si es el nivel activo
                  ),
                ],
              ),
              onPressed: () {
                _onLevelSelected(2); // Cambia al Nivel 911.
                setState(() => isFabExpanded = false); // Cierra el FAB.
              },
            ),
          ),
          Tooltip(
            message: 'Comida Rapida',
            child: FloatingActionButton.small(
              heroTag: 'levelComidaRapida',
              backgroundColor: _selectedLevel == 3
                  ? Colors.blueAccent[700]
                  : Colors
                      .blueAccent[50], // Cambia el color si es el nivel activo
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.fastfood,
                    color: _selectedLevel == 3
                        ? Colors.white
                        : Colors
                            .black, // Cambia el color del ícono si es el nivel activo
                  ),
                ],
              ),
              onPressed: () {
                _onLevelSelected(3); // Cambia al Nivel Comida Rápida.
                setState(() => isFabExpanded = false); // Cierra el FAB.
              },
            ),
          ),
          Tooltip(
            message: 'Marketplace',
            child: FloatingActionButton.small(
              heroTag: 'levelTiendas',
              backgroundColor: _selectedLevel == 4
                  ? Colors.blueAccent[700]
                  : Colors
                      .blueAccent[50], // Cambia el color si es el nivel activo
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.shopping_cart,
                    color: _selectedLevel == 4
                        ? Colors.white
                        : Colors
                            .black, // Cambia el color del ícono si es el nivel activo
                  ),
                ],
              ),
              onPressed: () {
                _onLevelSelected(4); // Cambia al Nivel Tiendas.
                setState(() => isFabExpanded = false); // Cierra el FAB.
              },
            ),
          ),
          Tooltip(
            message: 'TAXI',
            child: FloatingActionButton.small(
              heroTag: 'levelTaxi',
              backgroundColor: _selectedLevel == 5
                  ? Colors.blueAccent[700]
                  : Colors
                      .blueAccent[50], // Cambia el color si es el nivel activo
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.local_taxi,
                    color: _selectedLevel == 5
                        ? Colors.white
                        : Colors
                            .black, // Cambia el color del ícono si es el nivel activo
                  ),
                ],
              ),
              onPressed: () {
                _onLevelSelected(5); // Cambia al Nivel Taxi.
                setState(() => isFabExpanded = false); // Cierra el FAB.
              },
            ),
          ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        items: _bottomNavItems[_selectedLevel], // Cambia según el nivel.
        currentIndex: _bottomNavIndex,
        onTap: _onBottomNavTapped, // Cambia el índice al tocar.
        selectedItemColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.blueAccent[700]
            : Colors.orange, // Color del ítem seleccionado
        unselectedItemColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black, // Color de los ítems no seleccionados
      ),
    );
  }
}


class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  SignInScreenState createState() => SignInScreenState();
}

class SignInScreenState extends State<SignInScreen> {
  final GoogleSignInService googleSignInService = GoogleSignInService();
  final ApiService _apiService = ApiService();

  Future<void> _handleSignIn() async {
    
    final result = await googleSignInService.signInWithGoogle();
    
    if (result != null) {
      
      dynamic processedResult = result; // Nueva variable para procesar el result
      processedResult = jsonEncode(result);

      await _apiService.sendTokenToBackend(processedResult);
      // Puedes acceder a los datos del perfil aquí, si lo necesitas
      
      // var profile = result['profile'];
      // var token = result['token'];
     
      // logger.i(token +    '/++++/'  +  profile);

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Google Sign-In')),
      body: Center(
        child: ElevatedButton(
          onPressed: _handleSignIn,
          child: const Text('Iniciar sesión con Google'),
        ),
      ),
    );
  }
}


class LevelGas extends StatelessWidget {
  const LevelGas({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Nivel Gas'));
  }
}

class LevelDolar extends StatelessWidget {
  const LevelDolar({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Nivel Dólar'));
  }
}

class Level911 extends StatelessWidget {
  const Level911({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Nivel 911'));
  }
}

class LevelComidaRapida extends StatelessWidget {
  const LevelComidaRapida({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Nivel Comida Rápida'));
  }
}

class LevelTiendas extends StatelessWidget {
  const LevelTiendas({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Nivel Tiendas'));
  }
}

class LevelTaxi extends StatelessWidget {
  const LevelTaxi({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Nivel Taxi'));
  }
}