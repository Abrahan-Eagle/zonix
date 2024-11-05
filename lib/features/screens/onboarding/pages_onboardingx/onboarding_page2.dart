import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zonix/features/DomainProfiles/Profiles/screens/create_profile_page.dart';
import 'package:zonix/features/utils/user_provider.dart';

class OnboardingPage2 extends StatelessWidget {
  const OnboardingPage2({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      body: Container(
        color: const Color(0xff1eb090),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: FutureBuilder<Map<String, dynamic>>(
            future: userProvider.getUserDetails(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData) {
                return const Center(child: Text('No se encontraron datos.'));
              }

              final userDetails = snapshot.data!;
              final userId = userDetails['userId'];

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/onboarding/storefront-illustration-2.png'),
                  const SizedBox(height: 24),
                  Text(
                    'Crea tu perfil',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Ingresa tu información personal y crea tu perfil.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: userProvider.profileCreated ? null : () {
                      if (userId != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateProfilePage(userId: userId),
                          ),
                        ).then((_) {
                          userProvider.setProfileCreated(true);
                        });
                      }
                    },
                    icon: const Icon(Icons.person_add, color: Colors.white),
                    label: Text(
                      userProvider.profileCreated ? 'Perfil Creado' : 'Crear Perfil',
                      style: const TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: userProvider.profileCreated
                          ? Colors.grey
                          : const Color(0xff007d6e),
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}








// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:zonix/features/DomainProfiles/Profiles/screens/create_profile_page.dart';
// import 'package:zonix/features/utils/user_provider.dart';

// class OnboardingPage2 extends StatelessWidget {
//   const OnboardingPage2({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final userProvider = Provider.of<UserProvider>(context);

//     return Scaffold(
//       body: Container(
//         color: const Color(0xff1eb090),
//         child: Padding(
//           padding: const EdgeInsets.all(32.0),
//           child: FutureBuilder<Map<String, dynamic>>(
//             future: userProvider.getUserDetails(), // Espera el resultado del Future
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 // Muestra un indicador de carga mientras se espera el resultado
//                 return const Center(child: CircularProgressIndicator());
//               } else if (snapshot.hasError) {
//                 // Muestra un mensaje de error si ocurre algún problema
//                 return Center(child: Text('Error: ${snapshot.error}'));
//               } else if (!snapshot.hasData) {
//                 // Maneja el caso donde no hay datos
//                 return const Center(child: Text('No se encontraron datos.'));
//               }

//               // Extrae los datos del snapshot
//               final userDetails = snapshot.data!; // Usa `!` para asegurar que no sea null
//               final userId = userDetails['userId']; // Accede a userId
//               logger.i('User jojojojojojojojojojojojojojojojojojojojojojojojojojojojojojojojojojojojojojojojojojojojo: $userId');
//               return Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Image.asset('assets/onboarding/storefront-illustration-2.png'),
//                   const SizedBox(height: 24),
//                   Text(
//                     'Crea tu perfil',
//                     style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   const Text(
//                     'Ingresa tu información personal y crea tu perfil.',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(color: Colors.white),
//                   ),
//                   const SizedBox(height: 32), // Espacio entre el texto y el botón
//                   ElevatedButton.icon(
//                     onPressed: () {
//                       if (userId != null) {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => CreateProfilePage(userId: userId), // Pasar userId aquí
//                           ),
//                         );
//                       } else {
//                         logger.e('Error: El userId es null');
//                       }
//                     },
//                     icon: const Icon(Icons.person_add, color: Colors.white), // Ícono del botón
//                     label: const Text(
//                       'Crear Perfil',
//                       style: TextStyle(color: Colors.white),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xff007d6e), // Color del botón
//                       padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8.0),
//                       ),
//                     ),
//                   ),
//                 ],
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }
