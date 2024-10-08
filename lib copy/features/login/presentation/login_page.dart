import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:zonix/features/services/auth_service.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:zonix/features/home/presentation/home_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();
  GoogleSignInAccount? _currentUser;
  bool _isAuthorized = false;
  String _contactText = '';

  @override
  void initState() {
    super.initState();

    _authService.onCurrentUserChanged.listen((GoogleSignInAccount? account) async {
      bool isAuthorized = account != null;
      if (isAuthorized) {
        setState(() {
          _currentUser = account;
          _isAuthorized = isAuthorized;
        });
        _loadContacts(account!);
      }
    });

    _authService.signInSilently();
  }

  Future<void> _loadContacts(GoogleSignInAccount user) async {
    try {
      setState(() {
        _contactText = 'Loading contact info...';
      });
      final data = await _authService.getContact(user);
      final String? namedContact = _pickFirstNamedContact(data);
      setState(() {
        _contactText = namedContact != null
            ? 'I see you know $namedContact!'
            : 'No contacts to display.';
      });
    } catch (e) {
      setState(() {
        _contactText = 'Failed to load contacts.';
      });
    }
  }

  String? _pickFirstNamedContact(Map<String, dynamic> data) {
    final List<dynamic>? connections = data['connections'] as List<dynamic>?;
    final Map<String, dynamic>? contact = connections?.firstWhere(
      (dynamic contact) => (contact as Map<Object?, dynamic>)['names'] != null,
      orElse: () => null,
    ) as Map<String, dynamic>?;
    if (contact != null) {
      final List<dynamic> names = contact['names'] as List<dynamic>;
      final Map<String, dynamic>? name = names.firstWhere(
        (dynamic name) =>
            (name as Map<Object?, dynamic>)['displayName'] != null,
        orElse: () => null,
      ) as Map<String, dynamic>?;
      if (name != null) {
        return name['displayName'] as String?;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final GoogleSignInAccount? user = _currentUser;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Iniciar sesión'),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Text(
              'BIENVENIDO DE NUEVO...',
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 20),
            ),
            const Spacer(),
            if (user != null) ...[
              ListTile(
                leading: GoogleUserCircleAvatar(identity: user),
                title: Text(user.displayName ?? ''),
                subtitle: Text(user.email),
              ),
              const Text('Signed in successfully.'),
              if (_isAuthorized) Text(_contactText),
              ElevatedButton(
                onPressed: _authService.handleSignOut,
                child: const Text('SIGN OUT'),
              ),
            ] else ...[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: () {
                  // Acción para iniciar sesión con correo electrónico o usuario
                },
                child: const Text(
                  'Iniciar sesión email o usuario',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 10),

              // SignInButton de Google
              SignInButton(
                Buttons.google,
                text: 'Iniciar sesión con Google',
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15),
                onPressed: () {
                  _authService.handleSignIn();  // Inicia sesión con Google
                },
              ),

              const SizedBox(height: 10),

              // Botón para entrar al Dashboard
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  side: const BorderSide(color: Colors.indigo),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const MyHomePage(title: 'ZONIX Dashboard')),
                  );
                },
                child: const Text(
                  'Entrar al Dashboard',
                  style: TextStyle(fontSize: 16, color: Colors.indigo),
                ),
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
