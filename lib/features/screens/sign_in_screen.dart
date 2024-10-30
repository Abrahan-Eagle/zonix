import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:zonix/features/services/auth/api_service.dart';
import 'package:zonix/main.dart';
import 'package:zonix/features/services/auth/google_sign_in_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:zonix/features/utils/auth_utils.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_button/sign_in_button.dart';

const FlutterSecureStorage _storage = FlutterSecureStorage();
final ApiService apiService = ApiService();

// Configuración del logger
final logger = Logger();

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
      _currentUser = await GoogleSignInService.getCurrentUser();
      if (_currentUser != null) {
        logger.i('Foto de usuario: ${_currentUser!.photoUrl}'); // Verifica la URL aquí
        await _storage.write(key: 'userPhotoUrl', value: _currentUser!.photoUrl);
        logger.i('Nombre de usuario: ${_currentUser!.displayName}');
        await _storage.write(key: 'displayName', value: _currentUser!.displayName);
      }
    }
    setState(() {});
  }

  Future<void> _handleSignIn() async {
    await GoogleSignInService.signInWithGoogle();
    _currentUser = await GoogleSignInService.getCurrentUser();
    setState(() {});

    if (_currentUser != null) {
      await AuthUtils.saveUserName(_currentUser!.displayName ?? 'Nombre no disponible');
      await AuthUtils.saveUserEmail(_currentUser!.email ?? 'Email no disponible');
      await AuthUtils.saveUserPhotoUrl(_currentUser!.photoUrl ?? 'URL de foto no disponible');

      // Verificar que los datos se hayan guardado
      String? savedName = await _storage.read(key: 'userName');
      String? savedEmail = await _storage.read(key: 'userEmail');
      String? savedPhotoUrl = await _storage.read(key: 'userPhotoUrl');

      // Verifica en el log si los valores fueron correctamente almacenados
      logger.i('Nombre guardado: $savedName');
      logger.i('Correo guardado: $savedEmail');
      logger.i('Foto guardada: $savedPhotoUrl');

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
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'ZONI',
                style: TextStyle(
                  fontFamily: 'system-ui',
                  fontSize: 21,
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
                  fontSize: 21,
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
      ),
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

  Widget _buildSignInButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0), // Margen izquierdo y derecho
          child: const Text(
            '¡Hola! Inicia sesión para continuar.',
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 20),
          ),
        ),
        const SizedBox(height: 18),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0), // Margen izquierdo y derecho
          child: RichText(
            textAlign: TextAlign.left,
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Usa tu cuenta de Gmail para acceder a ',
                  style: TextStyle(
                    fontSize: 24, // Tamaño del texto normal
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black, // Color adaptado al tema
                  ),
                ),
                TextSpan(
                  text: 'ZONI',
                  style: TextStyle(
                    fontFamily: 'system-ui',
                    fontSize: 24, // Tamaño de fuente diferente para 'ZONIX'
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
                    fontSize: 24,
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
        ),

        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0), // Margen izquierdo y derecho
          child: Image.network(
            'https://i.ibb.co/cJqsPSB/scooter.png', // URL de la imagen
            fit: BoxFit.cover,
          ),
        ),

        const Spacer(),

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
