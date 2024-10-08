import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:zonix/features/utils/auth_utils.dart'; // Asegúrate de importar AuthUtils

class UserProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String _userName = '';
  String _userEmail = '';
  String _userPhotoUrl = '';

  // Getters para acceder a la información del usuario
  bool get isAuthenticated => _isAuthenticated;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userPhotoUrl => _userPhotoUrl;

  // Método que verifica si el usuario está autenticado
  Future<void> checkAuthentication() async {
    _isAuthenticated = await AuthUtils.isAuthenticated();
    
    // Si el usuario está autenticado, cargar los datos
    if (_isAuthenticated) {
      await loadUserData();
    }

    notifyListeners();
  }

  // Método para cargar la información del usuario desde almacenamiento seguro
  Future<void> loadUserData() async {
    _userName = await AuthUtils.getUserName() ?? '';
    _userEmail = await AuthUtils.getUserEmail() ?? '';
    _userPhotoUrl = await AuthUtils.getUserPhotoUrl() ?? '';
    notifyListeners();
  }

  // Método que almacena los datos del usuario cuando se autentica
  Future<void> setUserData(GoogleSignInAccount googleUser) async {
    _userName = googleUser.displayName ?? '';
    _userEmail = googleUser.email;
    _userPhotoUrl = googleUser.photoUrl ?? '';

    // Guardar los datos del usuario en almacenamiento seguro
    await AuthUtils.saveUserName(_userName);
    await AuthUtils.saveUserEmail(_userEmail);
    await AuthUtils.saveUserPhotoUrl(_userPhotoUrl);

    _isAuthenticated = true;
    notifyListeners();  // Notificar que el estado ha cambiado
  }

  // Método para cerrar sesión
  void logout() {
    _isAuthenticated = false;
    _userName = '';
    _userEmail = '';
    _userPhotoUrl = '';
    AuthUtils.logout();  // Cierra la sesión de manera correcta
    notifyListeners();
  }
}


// import 'package:flutter/material.dart';
// import 'package:zonix/features/utils/auth_utils.dart'; // Asegúrate de importar AuthUtils

// class UserProvider with ChangeNotifier {
//   bool _isAuthenticated = false;

//   // Getter para obtener el estado de autenticación
//   bool get isAuthenticated => _isAuthenticated;

//   // Método que verifica si el usuario está autenticado
//   Future<void> checkAuthentication() async {
//     _isAuthenticated = await AuthUtils.isAuthenticated();
//     notifyListeners();
//   }

//   // Método para cerrar sesión
//   void logout() {
//     _isAuthenticated = false;
//     AuthUtils.logout();  // Cierra la sesión de manera correcta
//     notifyListeners();
//   }
// }
