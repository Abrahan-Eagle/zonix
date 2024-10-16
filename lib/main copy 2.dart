import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:zonix/features/services/auth/api_service.dart';
import 'package:zonix/features/utils/user_provider.dart';
import 'package:zonix/features/screens/profile_page.dart';
import 'package:zonix/features/screens/settings_page_2.dart';
import 'package:zonix/features/screens/sign_in_screen.dart';
import 'package:zonix/features/GasTicket/screens/gas_ticket_list_screen.dart';
import 'package:logger/logger.dart';

const FlutterSecureStorage _storage = FlutterSecureStorage();
final ApiService apiService = ApiService();
final logger = Logger();

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  initialization();

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
          return userProvider.isAuthenticated ? const MainRouter() : const SignInScreen();
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
  }

  void _onLevelSelected(int level) {
    setState(() {
      _selectedLevel = level;
      _bottomNavIndex = 0; // Reinicia la selección de navegación inferior al cambiar el nivel
    });
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _bottomNavIndex = index;
    });
  }

  List<BottomNavigationBarItem> _getBottomNavItems() {
    switch (_selectedLevel) {
     case 1:
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.help), label: 'Ayuda1'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Configuración'),
        ];
      case 2:
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.help), label: 'Ayuda2'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Configuración'),
        ];
      case 3:
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.help), label: 'Ayuda3'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Configuración'),
        ];

      case 4:
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.help), label: 'Ayuda4'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Configuración'),
        ];

      case 5:
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.help), label: 'Ayuda5'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Configuración'),
        ];

      default:
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.help), label: 'Ayuda0'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Configuración'),
        ];
    }
  }

  Widget _getCenterContent() {
    switch (_selectedLevel) {
      case 0:
        switch (_bottomNavIndex) {
          case 0:
            return const Center(child: Text('Gas Information del boton de Inicio'));
          case 1:
            return const Center(child: Text('Gas Information del boton de Ayuda1'));
          case 2:
            return const Center(child: Text('Gas Information del boton de Configuración'));
          default:
            return const Center(child: Text('Gas Information Default'));
        }
      case 1:
        switch (_bottomNavIndex) {
          case 0:
            return const Center(child: Text('Dólares Compra/Venta del boton de Inicio'));
          case 1:
            return const Center(child: Text('Dólares Compra/Venta del boton de Ayuda2'));
          case 2:
            return const Center(child: Text('Dólares Compra/Venta del boton de Configuración'));
          default:
            return const Center(child: Text('Dólares Compra/Venta Default'));
        }
      case 2:
        switch (_bottomNavIndex) {
          case 0:
            return const Center(child: Text('911 Information del boton de Inicio'));
          case 1:
            return const Center(child: Text('911 Information del boton de Ayuda3'));
          case 2:
            return const Center(child: Text('911 Information del boton de Configuración'));
          default:
            return const Center(child: Text('911 Information Default'));
        }
      // Agrega otros niveles según sea necesario
      default:
        return const Center(child: Text('Default Information'));
    }
  }

  Widget _createLevelButton(int level, IconData icon, String tooltip) {
    return FloatingActionButton.small(
      heroTag: 'level$level',
      backgroundColor: _selectedLevel == level ? Colors.blueAccent[700] : Colors.blueAccent[50],
      child: Icon(icon, color: _selectedLevel == level ? Colors.white : Colors.black),
      onPressed: () => _onLevelSelected(level),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ZONIX'),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
                _createLevelButton(0, Icons.propane_tank, 'GAS'),
                _createLevelButton(1, Icons.attach_money, 'Dólares Compra/Venta'),
                _createLevelButton(2, Icons.local_police, '911'),
                _createLevelButton(3, Icons.fastfood, 'Comida Rápida'),
                _createLevelButton(4, Icons.store, 'Tiendas'),
                _createLevelButton(5, Icons.local_taxi, 'Taxis'),
            ],
          ),
          Expanded(child: _getCenterContent()),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: _getBottomNavItems(),
        currentIndex: _bottomNavIndex,
        onTap: _onBottomNavTapped,
      ),
    );
  }
}
