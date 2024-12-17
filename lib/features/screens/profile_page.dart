import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zonix/features/services/qr_profile_api_service.dart';
import 'package:zonix/features/utils/user_provider.dart';
import 'package:zonix/features/services/auth/google_sign_in_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:zonix/features/utils/auth_utils.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Importa QrImageView

final logger = Logger();

class ProfilePage1 extends StatefulWidget {
  const ProfilePage1({super.key});

  @override
  ProfilePage1State createState() => ProfilePage1State();
}

class ProfilePage1State extends State<ProfilePage1> {
  final GoogleSignInService googleSignInService = GoogleSignInService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  GoogleSignInAccount? currentUser;
  bool isAuthenticated = false;
  String? _profileId;

  
  Future<void> _initializeData() async {
    await _checkAuthentication();
    if (isAuthenticated) {
      await _fetchProfileId();
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    isAuthenticated = await AuthUtils.isAuthenticated();
    if (isAuthenticated) {
      currentUser = await GoogleSignInService.getCurrentUser();
      if (currentUser != null) {
        logger.i('Foto de usuario: ${currentUser!.photoUrl}');
        await _storage.write(key: 'userPhotoUrl', value: currentUser!.photoUrl);
        logger.i('Nombre de usuario: ${currentUser!.displayName}');
        await _storage.write(key: 'displayName', value: currentUser!.displayName);
      }
    }
    setState(() {});
  }

  Future<void> _fetchProfileId() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final profileId = await QrProfileApiService().sendUserIdToBackend(userProvider.userId);

      if (profileId != null) {
        _profileId = profileId; // Asigna directamente el ID de perfil
        await _storage.write(key: 'profileId', value: profileId);
        logger.i('ID de perfil obtenido: $profileId');
      } else {
        logger.e('No se pudo obtener el ID de perfil del backend');
      }
    } catch (e) {
      logger.e('Error al obtener el ID de perfil: $e');
    }
    setState(() {}); // Actualiza la interfaz de usuario
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      body: Column(
        children: [
          const Expanded(flex: 2, child: _TopPortion()),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  // Nombre del usuario
                  Text(
                    userProvider.userName.isNotEmpty
                        ? userProvider.userName
                        : (currentUser != null && currentUser!.displayName != null
                            ? currentUser!.displayName!
                            : "Usuario"), // Valor predeterminado
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  // ID del usuario
                  Text(
                    userProvider.userId != null && userProvider.userId.toString().isNotEmpty
                        ? "ID: ${userProvider.userId}"
                        : "ID no disponible",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  // ID de perfil (si está disponible)
                  if (_profileId != null)
                    Column(
                      children: [
                        Text(
                          "Profile ID: $_profileId",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        QrImageView(
                          data: _profileId!,
                          size: 200.0,
                          version: QrVersions.auto,
                          foregroundColor: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white // Color blanco si el tema es oscuro
                              : Colors.black, // Color negro si el tema es claro
                          backgroundColor: Colors.transparent,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopPortion extends StatelessWidget {
  const _TopPortion();

  @override
  Widget build(BuildContext context) {
    // final userProvider = Provider.of<UserProvider>(context);
    // Ajusta currentUser desde GoogleSignInService
    Future<GoogleSignInAccount?> getCurrentUser() async {
      return await GoogleSignInService.getCurrentUser();
    }

    return FutureBuilder<GoogleSignInAccount?>(
      future: getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Text('Error al obtener los datos del usuario');
        } else if (snapshot.hasData && snapshot.data != null) {
          final currentUser = snapshot.data!;
          return Stack(
            fit: StackFit.expand,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 50),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Color(0xff0043ba), Color(0xff006df1)],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(50),
                    bottomRight: Radius.circular(50),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: 150,
                  height: 150,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(currentUser.photoUrl!),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                          child: Container(
                            margin: const EdgeInsets.all(8.0),
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        } else {
          return const Text('Usuario no disponible');
        }
      },
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart'; // Asegúrate de importar provider
// import 'package:zonix/features/utils/user_provider.dart'; 
// import 'package:zonix/features/services/auth/google_sign_in_service.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:zonix/features/utils/auth_utils.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:logger/logger.dart';
// final GoogleSignInService googleSignInService = GoogleSignInService();
// final logger = Logger();
// bool isAuthenticated = false;
// GoogleSignInAccount? _currentUser;
// const FlutterSecureStorage _storage = FlutterSecureStorage();

// class ProfilePage1 extends StatefulWidget {
//   const ProfilePage1({super.key});

//   @override
//   ProfilePage1State createState() => ProfilePage1State();
// }

// class ProfilePage1State extends State<ProfilePage1> {
//   @override
//   void initState() {
//     super.initState();
//     _checkAuthentication();
//   }

  // Future<void> _checkAuthentication() async {
  //   isAuthenticated = await AuthUtils.isAuthenticated();
  //   if (isAuthenticated) {
  //     _currentUser = await GoogleSignInService.getCurrentUser();
  //     if (_currentUser != null) {
  //       logger.i('Foto de usuario: ${_currentUser!.photoUrl}');
  //       await _storage.write(key: 'userPhotoUrl', value: _currentUser!.photoUrl);
  //       logger.i('Nombre de usuario: ${_currentUser!.displayName}');
  //       await _storage.write(key: 'displayName', value: _currentUser!.displayName);
  //     }
  //   }
  //   setState(() {});
  // }

//   @override
//   Widget build(BuildContext context) {
//     final userProvider = Provider.of<UserProvider>(context, listen: false);

//     return Scaffold(
//       body: Column(
//         children: [
//           const Expanded(flex: 2, child: _TopPortion()),
//           Expanded(
//             flex: 3,
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 children: [
//                Text(
//                     userProvider.userName.isNotEmpty
//                         ? userProvider.userName
//                         : (_currentUser != null && _currentUser!.displayName != null
//                             ? _currentUser!.displayName!
//                             : "User"), // Valor predeterminado si no hay nombre
//                     style: Theme.of(context)
//                         .textTheme
//                         .titleLarge
//                         ?.copyWith(fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 16),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       FloatingActionButton.extended(
//                         onPressed: () {},
//                         heroTag: 'follow',
//                         elevation: 0,
//                         label: const Text("Follow"),
//                         icon: const Icon(Icons.person_add_alt_1),
//                       ),
//                       const SizedBox(width: 16.0),
//                       FloatingActionButton.extended(
//                         onPressed: () {},
//                         heroTag: 'message',
//                         elevation: 0,
//                         backgroundColor: Colors.red,
//                         label: const Text("Message"),
//                         icon: const Icon(Icons.message_rounded),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//                   const _ProfileInfoRow()
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _ProfileInfoRow extends StatelessWidget {
//   const _ProfileInfoRow();

//   final List<ProfileInfoItem> _items = const [
//     ProfileInfoItem("Posts", 900),
//     ProfileInfoItem("Followers", 120),
//     ProfileInfoItem("Following", 200),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 80,
//       constraints: const BoxConstraints(maxWidth: 400),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: _items
//             .map((item) => Expanded(
//                     child: Row(
//                   children: [
//                     if (_items.indexOf(item) != 0) const VerticalDivider(),
//                     Expanded(child: _singleItem(context, item)),
//                   ],
//                 )))
//             .toList(),
//       ),
//     );
//   }

//   Widget _singleItem(BuildContext context, ProfileInfoItem item) => Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Text(
//               item.value.toString(),
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 20,
//               ),
//             ),
//           ),
//           Text(
//             item.title,
//             style: Theme.of(context).textTheme.bodySmall,
//           )
//         ],
//       );
// }

// class ProfileInfoItem {
//   final String title;
//   final int value;
//   const ProfileInfoItem(this.title, this.value);
// }
// class _TopPortion extends StatelessWidget {
//   const _TopPortion();
  
//   @override
//   Widget build(BuildContext context) {
//     final userProvider = Provider.of<UserProvider>(context);

//     return Stack(
//       fit: StackFit.expand,
//       children: [
//         // Fondo con gradiente
//         Container(
//           margin: const EdgeInsets.only(bottom: 50),
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.bottomCenter,
//               end: Alignment.topCenter,
//               colors: [Color(0xff0043ba), Color(0xff006df1)],
//             ),
//             borderRadius: BorderRadius.only(
//               bottomLeft: Radius.circular(50),
//               bottomRight: Radius.circular(50),
//             ),
//           ),
//         ),
        
//         // Imagen de perfil o ícono predeterminado
//         Align(
//           alignment: Alignment.bottomCenter,
//           child: SizedBox(
//             width: 150,
//             height: 150,
//             child: Stack(
//               fit: StackFit.expand,
//               children: [
//                 Container(
//                   decoration: BoxDecoration(
//                     color: Colors.black,
//                     shape: BoxShape.circle,
                //     image: _currentUser != null && _currentUser!.photoUrl != null
                //       ? DecorationImage(
                //           fit: BoxFit.cover,
                //           image: NetworkImage(_currentUser!.photoUrl!),
                //         )
                //       : userProvider.userPhotoUrl.isNotEmpty
                //         ? DecorationImage(
                //             fit: BoxFit.cover,
                //             image: NetworkImage(userProvider.userPhotoUrl),
                //           )
                //         : null,
                //   ),
                  
                // ),
//                 // Indicador de estado (verde)
//                 Positioned(
//                   bottom: 0,
//                   right: 0,
//                   child: CircleAvatar(
//                     radius: 20,
//                     backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//                     child: Container(
//                       margin: const EdgeInsets.all(8.0),
//                       decoration: const BoxDecoration(
//                         color: Colors.green,
//                         shape: BoxShape.circle,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
