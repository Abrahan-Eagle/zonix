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
import 'package:provider/provider.dart';
import 'package:zonix/features/utils/user_provider.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';


const FlutterSecureStorage _storage = FlutterSecureStorage();
final ApiService _apiService = ApiService();

// Configuración del logger
final logger = Logger();

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  initialization(); // Lógica de inicialización.

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,  // Bloquea la orientación vertical
    DeviceOrientation.portraitDown,  // Bloquea la orientación vertical (opcional)
  ]);
  // runApp(const MyApp());
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
    // Inicializa el estado de autenticación al iniciar la app
    Provider.of<UserProvider>(context, listen: false).checkAuthentication();

    return MaterialApp(
      title: 'ZONIX',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.isAuthenticated) {
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
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Configuración'),
        ];
      case 1:
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.money), label: 'Finanzas'),
          BottomNavigationBarItem(icon: Icon(Icons.help), label: 'b'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Configuración'),
        ];
      case 2:
        return const [
          BottomNavigationBarItem(
              icon: Icon(Icons.business), label: 'Negocios'),
          BottomNavigationBarItem(icon: Icon(Icons.help), label: 'c'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Configuración'),
        ];
      // Agrega más casos según sea necesario
      default:
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.help), label: 'd'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Configuración'),
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
                const SettingsPage2()), // Navega a la pantalla de perfil
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
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.logout),
        //     onPressed: () async {
        //       await _handleLogout(); // Llama a la función de logout
        //     },
        //   ),
        // ]
        actions: [
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              return GestureDetector(
                onTap: () {
                  showMenu(
                    context: context,
                    position: const RelativeRect.fromLTRB(
                        200, 80, 0, 0), // Posición del menú
                    items: [
                      const PopupMenuItem<Menu>(
                        value: Menu.itemOne,
                        child: Text('Account'),
                      ),
                      PopupMenuItem<Menu>(
                        value: Menu.itemTwo,
                        child: const Text('Settings'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignInScreen()),
                          );
                        },
                      ),
                      PopupMenuItem<Menu>(
                        value: Menu.itemThree,
                        child: const Text('Sign Out'),
                        onTap: () async {
                          await _handleLogout(); // Llama a la función de logout
                        },
                      ),
                    ],
                  );
                },
                child: FutureBuilder<String?>(
                  future: _storage.read(key: 'userPhotoUrl'),
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

  //  Future<void> _handleLogout() async {
  //   try {
  //     final token = await _storage.read(key: 'token');
  //     if (token != null) {
  //       final response = await _apiService.logout(token);
  //       if (response.statusCode == 200) {
  //         // Elimina todos los datos
  //         await _storage.deleteAll();

  //         if (!mounted) return;

  //         Navigator.pushReplacement(
  //           context,
  //           MaterialPageRoute(builder: (context) => const SignInScreen()),
  //         );
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text('Sesión cerrada correctamente')),
  //         );
  //       } else {
  //         logger.e('Error: ${response.statusCode}');
  //         throw Exception('Error en la API al cerrar sesión');
  //       }
  //     }
  //   } catch (e) {
  //     logger.e('Error al cerrar sesión: $e');
  //   }
  // }

  Future<void> _handleLogout() async {
    try {
      final token = await _storage.read(key: 'token');
      if (token != null) {
        final response = await _apiService.logout(token);
        if (response.statusCode == 200) {
          // Elimina todos los datos
          await _storage.deleteAll();

          // Actualiza el estado de la sesión
          if (mounted) {
            // Solo accede al BuildContext si el widget está montado
            Provider.of<UserProvider>(context, listen: false)
                .checkAuthentication();
          }
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

enum Menu { itemOne, itemTwo, itemThree }

class ProfileIcon extends StatelessWidget {
  const ProfileIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Menu>(
        // icon: const Icon(Icons.person),
        offset: const Offset(0, 40),
        onSelected: (Menu item) {},
        itemBuilder: (BuildContext context) => <PopupMenuEntry<Menu>>[
              const PopupMenuItem<Menu>(
                value: Menu.itemOne,
                child: Text('Cuenta'),
              ),
              const PopupMenuItem<Menu>(
                value: Menu.itemTwo,
                child: Text('Configuración'),
              ),
              const PopupMenuItem<Menu>(
                value: Menu.itemThree,
                child: Text('Cerrar sesión'),
                //               onTap: () async {
                //               const ProfileIcon();
                // },
                // onPressed: () async {
                //         await _handleLogout(); // Llama a la función de logout
                // },

                // Llama a la función de logout, o cualquier otra lógica que quieras ejecutar
                // userProvider.logout();
                // Navigator.pushNamed(context, '/login');  // Redirige a la pantalla de login
              ),
            ]);
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

  // Future<void> _checkAuthentication() async {
  //   isAuthenticated = await AuthUtils.isAuthenticated();
  //   if (isAuthenticated) {
  //     _currentUser = await GoogleSignInService.getCurrentUser(); // Asegúrate de que este método devuelva un objeto de tipo GoogleUser
  //   }
  //   setState(() {});
  // }

  Future<void> _checkAuthentication() async {
    isAuthenticated = await AuthUtils.isAuthenticated();
    if (isAuthenticated) {
      _currentUser = await GoogleSignInService.getCurrentUser();
      if (_currentUser != null) {
        logger.i(
            'Foto de usuario: ${_currentUser!.photoUrl}'); // Verifica la URL aquí
        await _storage.write(
            key: 'userPhotoUrl', value: _currentUser!.photoUrl);
      }
    }
    setState(() {});
  }

  Future<void> _handleSignIn() async {
    await GoogleSignInService.signInWithGoogle();
    _currentUser = await GoogleSignInService.getCurrentUser();
    setState(() {});

    if (_currentUser != null) {
      logger.i('Inicio de sesión exitoso');
      logger.i(
          'Usuario: ${_currentUser!.displayName}, Correo: ${_currentUser!.email}');

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
      appBar: AppBar(title: const Text('Inicia sesión')),

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

  // // Botón de inicio de sesión
  // Widget _buildSignInButton() {
  //   return ElevatedButton(
  //     onPressed: _handleSignIn,
  //     child: const Text('Iniciar sesión con Google'),
  //   );
  // }


Widget _buildSignInButton() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      // Contenedor para el texto 'Hola'
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0), // Margen izquierdo y derecho
        child: const Text(
          'Hola',
          textAlign: TextAlign.left,
          style: TextStyle(fontSize: 30),
        ),
      ),
      const SizedBox(height: 16),

      // Contenedor para el texto explicativo
    Container(
  padding: const EdgeInsets.symmetric(horizontal: 20.0), // Margen izquierdo y derecho
  child: RichText(
    textAlign: TextAlign.left,
    text: TextSpan(
      children: [
        TextSpan(  // Eliminamos el const aquí
          text: 'Puedes usar tu cuenta Gmail, para registrarte y entrar a ',
          style: TextStyle(
            fontSize: 20, // Tamaño del texto normal
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black, // Color adaptado al tema
          ),
        ),
        TextSpan(
          text: 'ZONI', // Parte del texto con estilo especial
          style: TextStyle(
            fontFamily: 'system-ui',
            fontSize: 21, // Tamaño de fuente diferente para 'ZONIX'
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black, // Color adaptado al tema (oscuro o claro)
            letterSpacing: 1.2,
          ),
        ),
        TextSpan(
          text: 'X', // Parte del texto con estilo especial
          style: TextStyle(
            fontFamily: 'system-ui',
            fontSize: 21, // Tamaño de fuente diferente para 'ZONIX'
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.blueAccent[700]
                : Colors.orange, // Color adaptado al tema (oscuro o claro)
            letterSpacing: 1.2,
          ),
        ),
      ],
      
    ),
  ),
),


      const SizedBox(height: 24),

      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0), // Margen izquierdo y derecho
        child: Image.network(
          'https://i.ibb.co/cJqsPSB/scooter.png', // URL de la imagen
          fit: BoxFit.cover, // Puedes ajustar el ajuste de la imagen si es necesario
          // width: 200, // Ajusta el ancho si es necesario
          // height: 200, // Ajusta la altura si es necesario
        ),
      ),

      // const SizedBox(height: 24),
      // Aquí puedes dejar espacio en la parte superior para ajustar el contenido
      const Spacer(),

      // Contenedor para el botón de inicio de sesión con Google
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0), // Margen izquierdo y derecho
        child: SignInButton(
          Buttons.google,
          text: 'Iniciar sesión con Google',
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
          onPressed: _handleSignIn,
        ),
      ),
       const SizedBox(height: 30),
    ],
  );
}

}



class SettingsPage2 extends StatefulWidget {
  const SettingsPage2({super.key});

  @override
  State<SettingsPage2> createState() => _SettingsPage2State();
}

class _SettingsPage2State extends State<SettingsPage2> {
  @override
  Widget build(BuildContext context) {
    // Obtiene el UserProvider, asegurándote de que no se escuche cambios innecesarios
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Configuraciones"),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: ListView(
            children: [
              _buildGeneralSection(),
              const Divider(),
              _buildOrganizationSection(),
              const Divider(),
              _buildHelpAndLogoutSection(userProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGeneralSection() {
    return const _SingleSection(
      title: "General",
      children: [
        _CustomListTile(
          title: "Notificaciones",
          icon: Icons.notifications_none_rounded,
        ),
        _CustomListTile(
          title: "Estado de Seguridad",
          icon: CupertinoIcons.lock_shield,
        ),
      ],
    );
  }

  Widget _buildOrganizationSection() {
    return const _SingleSection(
      title: "Organización",
      children: [
        _CustomListTile(
          title: "Perfil",
          icon: Icons.person_outline_rounded,
        ),
        _CustomListTile(
          title: "Mensajes",
          icon: Icons.message_outlined,
        ),
        _CustomListTile(
          title: "Llamadas",
          icon: Icons.phone_outlined,
        ),
        _CustomListTile(
          title: "Personas",
          icon: Icons.contacts_outlined,
        ),
        _CustomListTile(
          title: "Calendario",
          icon: Icons.calendar_today_rounded,
        ),
      ],
    );
  }

  Widget _buildHelpAndLogoutSection(UserProvider userProvider) {
    return _SingleSection(
      children: [
        const _CustomListTile(
          title: "Ayuda y Comentarios",
          icon: Icons.help_outline_rounded,
        ),
        const _CustomListTile(
          title: "Acerca de",
          icon: Icons.info_outline_rounded,
        ),
        _CustomListTile(
          title: "Cerrar sesión",
          icon: Icons.exit_to_app_rounded,
          // Pasa la función logout como una referencia
          onTap: () async {
            await userProvider.logout();
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SignInScreen()),
            );
          },
        ),
      ],
    );
  }
}

class _CustomListTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final GestureTapCallback? onTap;

  const _CustomListTile({
    required this.title,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      leading: Icon(icon),
      onTap: onTap,
    );
  }
}

class _SingleSection extends StatelessWidget {
  final String? title;
  final List<Widget> children;

  const _SingleSection({this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title!,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        Column(
          children: children,
        ),
      ],
    );
  }
}
