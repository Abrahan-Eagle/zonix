import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:logger/logger.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
import 'package:zonix/features/GasTicket/another_button/screens/other_screen.dart';
import 'package:zonix/features/GasTicket/gas_button/screens/gas_ticket_list_screen.dart'; // Asegúrate de importar esta pantalla
// import 'dart:io';
// import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

const FlutterSecureStorage _storage = FlutterSecureStorage();
final ApiService apiService = ApiService();


  final String baseUrl = const bool.fromEnvironment('dart.vm.product')
      ? dotenv.env['API_URL_PROD']!
      : dotenv.env['API_URL_LOCAL']!;



// Configuración del logger
final logger = Logger();

//  class MyHttpOverrides extends HttpOverrides{
//   @override
//   HttpClient createHttpClient(SecurityContext? context){
//     return super.createHttpClient(context)
//       ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
//   }
// }

// void main() {
Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  initialization();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);



 await dotenv.load();
  //  HttpOverrides.global = MyHttpOverrides();
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
      logger.i('Loaded last position - selectedLevel: $_selectedLevel, bottomNavIndex: $_bottomNavIndex');
    });
  }

  Future<void> _saveLastPosition() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedLevel', _selectedLevel);
    await prefs.setInt('bottomNavIndex', _bottomNavIndex);
    logger.i('Saved last position - selectedLevel: $_selectedLevel, bottomNavIndex: $_bottomNavIndex');
  }

  Future<Map<String, dynamic>> _getUserDetails() async {
    final token = await _storage.read(key: 'token');
    logger.i('Retrieved token: $token');
    final response = await http.get(
      Uri.parse('$baseUrl/api/auth/user'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

     if (response.statusCode == 200) {
      final userDetails = jsonDecode(response.body);
      final role = await _storage.read(key: 'role'); // Asegúrate de que el rol se esté almacenando correctamente
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
    if (index == 2) {
      // Navega a la pantalla de configuración
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SettingsPage2(),
        ),
      );
    } else {
      setState(() {
        _bottomNavIndex = index;
        logger.i('Bottom nav index changed to: $_bottomNavIndex');
        _saveLastPosition();
      });
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
                  MaterialPageRoute(
                      builder: (context) => const ProfilePage1()),
                ),
              ),
              PopupMenuItem(
                child: const Text('Configuración'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsPage2()),
                ),
              ),
              PopupMenuItem(
                child: const Text('Cerrar sesión'),
                onTap: () async {
                  await _storage.deleteAll();
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignInScreen()));
                },
              ),
            ],
          );
        },
        child: FutureBuilder<String?>(
          future: _storage.read(key: 'userPhotoUrl'), // Leer la URL de la foto
          builder:
              (BuildContext context, AsyncSnapshot<String?> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircleAvatar(
                radius: 20,
              );
            } else if (snapshot.hasError ||
                snapshot.data == null ||
                snapshot.data!.isEmpty) {
              return const CircleAvatar(
                radius: 20,
                child: Icon(Icons.person), // Icono de usuario predeterminado
              );
            } else {
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: CircleAvatar(
                  radius: 20,
                  child: ClipOval(
                    child: Image.network(
                      snapshot.data!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            }
          },
        ),
      );
    },
  ),
],



      ),
      // body: FutureBuilder<Map<String, dynamic>>(
      //   future: _getUserDetails(),
      //   builder: (context, snapshot) {
      //     if (snapshot.connectionState == ConnectionState.waiting) {
      //       return const Center(child: CircularProgressIndicator());
      //     } else if (snapshot.hasError) {
      //       logger.e('Error fetching user details: ${snapshot.error}');
      //       return Center(child: Text('Error: ${snapshot.error}'));
      //     } else {
      //       final role = snapshot.data!['role'] ?? 'guest'; // Usa un valor predeterminado
      //       logger.i('Role fetched: $role');
      //       return Center(
      //         child: Text('Rol: $role', style: const TextStyle(fontSize: 24)),
      //       );
      //     }
      //   },
      // ),

        body: FutureBuilder<Map<String, dynamic>>(
      future: _getUserDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          logger.e('Error fetching user details: ${snapshot.error}');
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final role = snapshot.data!['role'] ?? 'guest'; // Usa un valor predeterminado
          logger.i('Role fetched: $role');

          // Verificar el nivel y el botón de inicio
          if (_selectedLevel == 0 && _bottomNavIndex == 0) {
            return const GasTicketListScreen(); // Reemplaza por tu pantalla
          } 
           if (_selectedLevel == 0 && _bottomNavIndex == 1) {
            return const OtherScreen(); // Reemplaza por tu pantalla
          } 
          
          
          
          else {
            return Center(
              child: Text('Rol: $role', style: const TextStyle(fontSize: 24)),
            );
          }
        }
      },
    ),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        distance: 70,
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
        items: _getBottomNavItems(_selectedLevel),
        currentIndex: _bottomNavIndex,
        selectedItemColor: Colors.blueAccent, // Color del ícono activo
        unselectedItemColor: Colors.grey, // Color del ícono inactivo
        onTap: _onBottomNavTapped,
      ),
    );
  }
}
