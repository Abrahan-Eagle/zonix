// import 'package:flutter/material.dart';
// import 'package:logger/logger.dart';
// import 'package:provider/provider.dart';
// import 'package:zonix/features/DomainProfiles/Documents/screens/document_list_screen.dart';
// import 'package:zonix/features/DomainProfiles/Emails/screens/email_list_screen.dart';
// import 'package:zonix/features/DomainProfiles/Phones/screens/phone_list_screen.dart';
// import 'package:zonix/features/utils/user_provider.dart';
// import 'package:zonix/features/DomainProfiles/GasCylinder/screens/gas_cylinder_list_screen.dart';
// import 'package:zonix/features/DomainProfiles/Profiles/screens/profile_page.dart';
// import 'package:zonix/features/screens/sign_in_screen.dart';
// import 'package:zonix/features/DomainProfiles/Addresses/screens/adresse_list_screen.dart';
// import 'package:zonix/features/screens/about/about_page.dart';
// import 'package:zonix/features/screens/HelpAndFAQPage/help_and_faq_page.dart';

// final logger = Logger();

// class SettingsPage2 extends StatefulWidget {
//   const SettingsPage2({super.key});

//   @override
//   State<SettingsPage2> createState() => _SettingsPage2State();
// }

// class _SettingsPage2State extends State<SettingsPage2> {
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<UserProvider>(
//       builder: (context, userProvider, child) {
//         return Scaffold(
//           body: Stack(
//             children: [
//               // Fondo con imagen
//               Image.network(
//                 'https://i.pinimg.com/736x/16/a4/f6/16a4f66ff40d30c7a8fa1fe44b1e3c3e.jpg',
//                 width: MediaQuery.sizeOf(context).width,
//                 height: MediaQuery.sizeOf(context).height,
//                 fit: BoxFit.cover,
//               ),
//               // Gradiente
//               Container(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
//                 child: SingleChildScrollView(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Título y subtítulo
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           const Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Configuraciones',
//                                 style: TextStyle(
//                                   color: Color(0xFF00F0FF),
//                                   fontSize: 28,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               Text(
//                                 'Panel de Control',
//                                 style: TextStyle(
//                                   color: Color(0xFF32FF7E),
//                                   fontSize: 16,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           // Imagen de perfil
//                           Container(
//                             width: 50,
//                             height: 50,
//                             decoration: BoxDecoration(
//                               color: Colors.white.withOpacity(0.2),
//                               shape: BoxShape.circle,
//                               border: Border.all(color: const Color(0xFF00F0FF), width: 2),
//                             ),
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(25),
//                               child: Image.network(
//                                 'https://images.unsplash.com/photo-1647797336045-8d3d36ef7c3c?w=500&h=500',
//                                 fit: BoxFit.cover,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 24),
//                       // Sección de Configuración General
//                       _buildGridSection(
//                         userProvider,
//                         title: "Configuración General",
//                         items: [
//                           _GridItem(
//                             title: "Perfil",
//                             icon: Icons.person_outline,
//                             color: const Color(0xFF00FFFF),
//                             onTap: () => _navigateTo(context, ProfilePagex(userId: userProvider.userId)),
//                           ),
//                           _GridItem(
//                             title: "Documentos",
//                             icon: Icons.folder_outlined,
//                             color: const Color(0xFF8A2BE2),
//                             onTap: () => _navigateTo(context, DocumentListScreen(userId: userProvider.userId)),
//                           ),
//                           _GridItem(
//                             title: "Dirección",
//                             icon: Icons.location_on_outlined,
//                             color: const Color(0xFFFFB347),
//                             onTap: () => _navigateTo(context, AddressPage(userId: userProvider.userId)),
//                           ),
//                           _GridItem(
//                             title: "Bombonas de Gas",
//                             icon: Icons.gas_meter_outlined,
//                             color: const Color(0xFF00FFFF),
//                             onTap: () => _navigateTo(context, GasCylinderListScreen(userId: userProvider.userId)),
//                           ),
//                           _GridItem(
//                             title: "Teléfonos",
//                             icon: Icons.phone_outlined,
//                             color: const Color(0xFF8A2BE2),
//                             onTap: () => _navigateTo(context, PhoneScreen(userId: userProvider.userId)),
//                           ),
//                           _GridItem(
//                             title: "Correos",
//                             icon: Icons.email_outlined,
//                             color: const Color(0xFFFFB347),
//                             onTap: () => _navigateTo(context, EmailListScreen(userId: userProvider.userId)),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 24),
//                       // Sección de Administración y Seguridad
//                       _buildGridSection(
//                         userProvider,
//                         title: "Administración y Seguridad",
//                         items: [
//                           _GridItem(
//                             title: "Ayuda",
//                             icon: Icons.help_outline,
//                             color: const Color(0xFF8A2BE2),
//                             onTap: () => _navigateTo(context, const HelpAndFAQPage()),
//                           ),
//                           _GridItem(
//                             title: "Acerca de",
//                             icon: Icons.info_outline,
//                             color: const Color(0xFFFFB347),
//                             onTap: () => _navigateTo(context, const MyApp()),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 24),
//                       // Cerrar sesión (botón grande)
//                      Padding(
//   padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
//   child: GestureDetector(
//     onTap: () async {
//       await userProvider.logout();
//       if (!mounted) return;
//       Navigator.of(context).pushAndRemoveUntil(
//         MaterialPageRoute(builder: (context) => const SignInScreen()),
//         (route) => false,
//       );
//     },
//     child: Container(
//       width: double.infinity, // Esto hará que el botón ocupe todo el ancho disponible
//       decoration: BoxDecoration(
//         color: const Color(0x1A000000),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: const Color(0x33FFFFFF),
//           width: 1,
//         ),
//       ),
//       child: const Padding(
//         padding: EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
//         child: Row(
//           mainAxisSize: MainAxisSize.max,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.logout,
//               color: Color(0xFFFF5963),
//               size: 24,
//             ),
//             SizedBox(width: 12),
//             Text(
//               'Cerrar Sesión',
//               style: TextStyle(
//                 fontFamily: 'Inter',
//                 color: Color(0xFFFF5963),
//                 fontSize: 16,
//               ),
//             ),
//           ],
//         ),
//       ),
//     ),
//   ),
// ),

//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   // Navegación
//   void _navigateTo(BuildContext context, Widget screen) {
//     Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
//   }

//   // Construcción de secciones en grid
//   Widget _buildGridSection(UserProvider userProvider,
//       {required String title, required List<_GridItem> items}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 12),
//         GridView.builder(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 2,
//             crossAxisSpacing: 16,
//             mainAxisSpacing: 16,
//             childAspectRatio: 1.3,
//           ),
//           itemCount: items.length,
//           itemBuilder: (context, index) {
//             final item = items[index];
//             return GestureDetector(
//               onTap: item.onTap,
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Colors.black.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(color: Colors.white.withOpacity(0.3)),
//                 ),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(item.icon, color: item.color, size: 32),
//                     const SizedBox(height: 8),
//                     Text(
//                       item.title,
//                       style: const TextStyle(color: Colors.white),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ],
//     );
//   }
// }

// class _GridItem {
//   final String title;
//   final IconData icon;
//   final Color color;
//   final VoidCallback? onTap;

//   _GridItem({
//     required this.title,
//     required this.icon,
//     required this.color,
//     this.onTap,
//   });
// }


// import 'package:flutter/material.dart';
// import 'package:logger/logger.dart';
// import 'package:provider/provider.dart';
// import 'package:zonix/features/DomainProfiles/Documents/screens/document_list_screen.dart';
// import 'package:zonix/features/DomainProfiles/Emails/screens/email_list_screen.dart';
// import 'package:zonix/features/DomainProfiles/Phones/screens/phone_list_screen.dart';
// import 'package:zonix/features/utils/user_provider.dart';
// import 'package:zonix/features/DomainProfiles/GasCylinder/screens/gas_cylinder_list_screen.dart';
// import 'package:zonix/features/DomainProfiles/Profiles/screens/profile_page.dart';
// import 'package:zonix/features/screens/sign_in_screen.dart';
// import 'package:zonix/features/DomainProfiles/Addresses/screens/adresse_list_screen.dart';
// import 'package:zonix/features/screens/about/about_page.dart';
// import 'package:zonix/features/screens/HelpAndFAQPage/help_and_faq_page.dart';

// final logger = Logger();

// class SettingsPage2 extends StatefulWidget {
//   const SettingsPage2({super.key});

//   @override
//   State<SettingsPage2> createState() => _SettingsPage2State();
// }

// class _SettingsPage2State extends State<SettingsPage2> {
//   @override
//   Widget build(BuildContext context) {
//     final brightness = Theme.of(context).brightness;
//     return Consumer<UserProvider>(
//       builder: (context, userProvider, child) {
//         return Scaffold(
//           body: Stack(
//             children: [
//               // Fondo con imagen
//               // Image.network(
//               //   'https://i.pinimg.com/736x/16/a4/f6/16a4f66ff40d30c7a8fa1fe44b1e3c3e.jpg',
//               //   width: MediaQuery.sizeOf(context).width,
//               //   height: MediaQuery.sizeOf(context).height,
//               //   fit: BoxFit.cover,
//               // ),

//               Image.asset(
//                 Theme.of(context).brightness == Brightness.dark
//                     ? 'assets/images/profile_photos/16a4f66ff40d30c7a8fa1fe44b1e3c3e.jpg' // Imagen para el modo oscuro
//                     : 'assets/images/profile_photos/HD-wallpaper-floating-in-asteroids-astronaut-asteroid-belt-space.jpg', // Imagen para el modo claro
//                 width: MediaQuery.sizeOf(context).width,
//                 height: MediaQuery.sizeOf(context).height,
//                 fit: BoxFit.cover,
//               ),



//               // Gradiente
//               Container(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
//                 child: SingleChildScrollView(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Título y subtítulo
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           const Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Configuraciones',
//                                 style: TextStyle(
//                                   color: Color(0xFF00F0FF),
//                                   fontSize: 28,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               Text(
//                                 'Panel de Control',
//                                 style: TextStyle(
//                                   color: Color(0xFF32FF7E),
//                                   fontSize: 16,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           // Imagen de perfil
//                           Container(
//                             width: 50,
//                             height: 50,
//                             decoration: BoxDecoration(
//                               color: brightness == Brightness.dark
//                                   ? Colors.white.withOpacity(0.2)
//                                   : Colors.black.withOpacity(0.2),
//                               shape: BoxShape.circle,
//                               border: Border.all(
//                                   color: brightness == Brightness.dark
//                                       ? const Color(0xFF00F0FF)
//                                       : const Color(0xFF32FF7E),
//                                   width: 2),
//                             ),
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(25),
//                               child: Image.network(
//                                 'https://images.unsplash.com/photo-1647797336045-8d3d36ef7c3c?w=500&h=500',
//                                 fit: BoxFit.cover,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 24),
//                       // Sección de Configuración General
//                       _buildGridSection(
//                         userProvider,
//                         title: "Configuración General",
//                         items: [
//                           _GridItem(
//                             title: "Perfil",
//                             icon: Icons.person_outline,
//                             color: brightness == Brightness.dark
//                                 ? const Color(0xFF00FFFF)
//                                 : const Color(0xFF8A2BE2),
//                             onTap: () => _navigateTo(context, ProfilePagex(userId: userProvider.userId)),
//                           ),
//                           _GridItem(
//                             title: "Documentos",
//                             icon: Icons.folder_outlined,
//                             color: brightness == Brightness.dark
//                                 ? const Color(0xFF8A2BE2)
//                                 : const Color(0xFFFFB347),
//                             onTap: () => _navigateTo(context, DocumentListScreen(userId: userProvider.userId)),
//                           ),
//                           _GridItem(
//                             title: "Dirección",
//                             icon: Icons.location_on_outlined,
//                             color: brightness == Brightness.dark
//                                 ? const Color(0xFFFFB347)
//                                 : const Color(0xFF00FFFF),
//                             onTap: () => _navigateTo(context, AddressPage(userId: userProvider.userId)),
//                           ),
//                           _GridItem(
//                             title: "Bombonas de Gas",
//                             icon: Icons.gas_meter_outlined,
//                             color: brightness == Brightness.dark
//                                 ? const Color(0xFF00FFFF)
//                                 : const Color(0xFF8A2BE2),
//                             onTap: () => _navigateTo(context, GasCylinderListScreen(userId: userProvider.userId)),
//                           ),
//                           _GridItem(
//                             title: "Teléfonos",
//                             icon: Icons.phone_outlined,
//                             color: brightness == Brightness.dark
//                                 ? const Color(0xFF8A2BE2)
//                                 : const Color(0xFFFFB347),
//                             onTap: () => _navigateTo(context, PhoneScreen(userId: userProvider.userId)),
//                           ),
//                           _GridItem(
//                             title: "Correos",
//                             icon: Icons.email_outlined,
//                             color: brightness == Brightness.dark
//                                 ? const Color(0xFFFFB347)
//                                 : const Color(0xFF00FFFF),
//                             onTap: () => _navigateTo(context, EmailListScreen(userId: userProvider.userId)),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 24),
//                       // Sección de Administración y Seguridad
//                       _buildGridSection(
//                         userProvider,
//                         title: "Administración y Seguridad",
//                         items: [
//                           _GridItem(
//                             title: "Ayuda",
//                             icon: Icons.help_outline,
//                             color: brightness == Brightness.dark
//                                 ? const Color(0xFF8A2BE2)
//                                 : const Color(0xFFFFB347),
//                             onTap: () => _navigateTo(context, const HelpAndFAQPage()),
//                           ),
//                           _GridItem(
//                             title: "Acerca de",
//                             icon: Icons.info_outline,
//                             color: brightness == Brightness.dark
//                                 ? const Color(0xFFFFB347)
//                                 : const Color(0xFF8A2BE2),
//                             onTap: () => _navigateTo(context, const MyApp()),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 24),
//                       // Cerrar sesión (botón grande)
//                       Padding(
//                         padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
//                         child: GestureDetector(
//                           onTap: () async {
//                             await userProvider.logout();
//                             if (!mounted) return;
//                             Navigator.of(context).pushAndRemoveUntil(
//                               MaterialPageRoute(builder: (context) => const SignInScreen()),
//                               (route) => false,
//                             );
//                           },
//                           child: Container(
//                             width: double.infinity, // Esto hará que el botón ocupe todo el ancho disponible
//                             decoration: BoxDecoration(
//                               color: brightness == Brightness.dark
//                                   ? const Color(0x1A000000)
//                                   : const Color(0x33FFFFFF),
//                               borderRadius: BorderRadius.circular(16),
//                               border: Border.all(
//                                 color: brightness == Brightness.dark
//                                     ? const Color(0x33FFFFFF)
//                                     : const Color(0x1A000000),
//                                 width: 1,
//                               ),
//                             ),
//                             child: const Padding(
//                               padding: EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
//                               child: Row(
//                                 mainAxisSize: MainAxisSize.max,
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Icon(
//                                     Icons.logout,
//                                     color: Color(0xFFFF5963),
//                                     size: 24,
//                                   ),
//                                   SizedBox(width: 12),
//                                   Text(
//                                     'Cerrar Sesión',
//                                     style: TextStyle(
//                                       fontFamily: 'Inter',
//                                       // color: Color(0xFFFF5963),
//                                          color: brightness == Brightness.dark
//                                           ?  Color(0xFF8A2BE2)
//                                           :  Color(0xFFFF5963),
//                                       fontSize: 16,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   // Navegación
//   void _navigateTo(BuildContext context, Widget screen) {
//     Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
//   }

//   // Construcción de secciones en grid
//   Widget _buildGridSection(UserProvider userProvider,
//       {required String title, required List<_GridItem> items}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 12),
//         GridView.builder(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 2,
//             crossAxisSpacing: 16,
//             mainAxisSpacing: 16,
//             childAspectRatio: 1.3,
//           ),
//           itemCount: items.length,
//           itemBuilder: (context, index) {
//             final item = items[index];
//             return GestureDetector(
//               onTap: item.onTap,
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Colors.black.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(color: Colors.white.withOpacity(0.3)),
//                 ),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(item.icon, color: item.color, size: 32),
//                     const SizedBox(height: 8),
//                     Text(
//                       item.title,
//                       style: const TextStyle(color: Colors.white),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ],
//     );
//   }
// }

// class _GridItem {
//   final String title;
//   final IconData icon;
//   final Color color;
//   final VoidCallback? onTap;

//   _GridItem({
//     required this.title,
//     required this.icon,
//     required this.color,
//     this.onTap,
//   });
// }


import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:zonix/features/DomainProfiles/Documents/screens/document_list_screen.dart';
import 'package:zonix/features/DomainProfiles/Emails/screens/email_list_screen.dart';
import 'package:zonix/features/DomainProfiles/Phones/screens/phone_list_screen.dart';
import 'package:zonix/features/utils/user_provider.dart';
import 'package:zonix/features/DomainProfiles/GasCylinder/screens/gas_cylinder_list_screen.dart';
import 'package:zonix/features/DomainProfiles/Profiles/screens/profile_page.dart';
import 'package:zonix/features/screens/sign_in_screen.dart';
import 'package:zonix/features/DomainProfiles/Addresses/screens/adresse_list_screen.dart';
import 'package:zonix/features/screens/about/about_page.dart';
import 'package:zonix/features/screens/HelpAndFAQPage/help_and_faq_page.dart';

final logger = Logger();

class SettingsPage2 extends StatefulWidget {
  const SettingsPage2({super.key});

  @override
  State<SettingsPage2> createState() => _SettingsPage2State();
}

class _SettingsPage2State extends State<SettingsPage2> {
  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return Scaffold(
          body: Stack(
            children: [
              // Fondo con imagen
              Image.asset(
                Theme.of(context).brightness == Brightness.dark
                    ? 'assets/images/profile_photos/16a4f66ff40d30c7a8fa1fe44b1e3c3e.jpg' // Imagen para el modo oscuro
                    : 'assets/images/profile_photos/HD-wallpaper-floating-in-asteroids-astronaut-asteroid-belt-space.jpg', // Imagen para el modo claro
                width: MediaQuery.sizeOf(context).width,
                height: MediaQuery.sizeOf(context).height,
                fit: BoxFit.cover,
              ),

              // Gradiente
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título y subtítulo
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Configuraciones',
                                style: TextStyle(
                                  color: Color(0xFF00F0FF),
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Panel de Control',
                                style: TextStyle(
                                  color: Color(0xFF32FF7E),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          // Imagen de perfil
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: brightness == Brightness.dark
                                  ? Colors.white.withOpacity(0.2)
                                  : Colors.black.withOpacity(0.2),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: brightness == Brightness.dark
                                      ? const Color(0xFF00F0FF)
                                      : const Color(0xFF32FF7E),
                                  width: 2),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(25),
                              child: Image.network(
                                'https://images.unsplash.com/photo-1647797336045-8d3d36ef7c3c?w=500&h=500',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Sección de Configuración General
                      _buildGridSection(
                        userProvider,
                        title: "Configuración General",
                        items: [
                          _GridItem(
                            title: "Perfil",
                            icon: Icons.person_outline,
                            color: brightness == Brightness.dark
                                ? const Color(0xFF00FFFF)
                                : const Color(0xFF8A2BE2),
                            onTap: () => _navigateTo(context, ProfilePagex(userId: userProvider.userId)),
                          ),
                          _GridItem(
                            title: "Documentos",
                            icon: Icons.folder_outlined,
                            color: brightness == Brightness.dark
                                ? const Color(0xFF8A2BE2)
                                : const Color(0xFFFFB347),
                            onTap: () => _navigateTo(context, DocumentListScreen(userId: userProvider.userId)),
                          ),
                          _GridItem(
                            title: "Dirección",
                            icon: Icons.location_on_outlined,
                            color: brightness == Brightness.dark
                                ? const Color(0xFFFFB347)
                                : const Color(0xFF00FFFF),
                            onTap: () => _navigateTo(context, AddressPage(userId: userProvider.userId)),
                          ),
                          _GridItem(
                            title: "Bombonas de Gas",
                            icon: Icons.gas_meter_outlined,
                            color: brightness == Brightness.dark
                                ? const Color(0xFF00FFFF)
                                : const Color(0xFF8A2BE2),
                            onTap: () => _navigateTo(context, GasCylinderListScreen(userId: userProvider.userId)),
                          ),
                          _GridItem(
                            title: "Teléfonos",
                            icon: Icons.phone_outlined,
                            color: brightness == Brightness.dark
                                ? const Color(0xFF8A2BE2)
                                : const Color(0xFFFFB347),
                            onTap: () => _navigateTo(context, PhoneScreen(userId: userProvider.userId)),
                          ),
                          _GridItem(
                            title: "Correos",
                            icon: Icons.email_outlined,
                            color: brightness == Brightness.dark
                                ? const Color(0xFFFFB347)
                                : const Color(0xFF00FFFF),
                            onTap: () => _navigateTo(context, EmailListScreen(userId: userProvider.userId)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Sección de Administración y Seguridad
                      _buildGridSection(
                        userProvider,
                        title: "Administración y Seguridad",
                        items: [
                          _GridItem(
                            title: "Ayuda",
                            icon: Icons.help_outline,
                            color: brightness == Brightness.dark
                                ? const Color(0xFF8A2BE2)
                                : const Color(0xFFFFB347),
                            onTap: () => _navigateTo(context, const HelpAndFAQPage()),
                          ),
                          _GridItem(
                            title: "Acerca de",
                            icon: Icons.info_outline,
                            color: brightness == Brightness.dark
                                ? const Color(0xFFFFB347)
                                : const Color(0xFF8A2BE2),
                            onTap: () => _navigateTo(context, const MyApp()),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Cerrar sesión (botón grande)
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                        child: GestureDetector(
                          onTap: () async {
                            await userProvider.logout();
                            if (!mounted) return;
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (context) => const SignInScreen()),
                              (route) => false,
                            );
                          },
                          child: Container(
                            width: double.infinity, // Esto hará que el botón ocupe todo el ancho disponible
                            // decoration: BoxDecoration(
                            //   color: brightness == Brightness.dark
                            //       ? const Color(0x1A000000)
                            //       : const Color(0x33FFFFFF),
                            //   borderRadius: BorderRadius.circular(16),
                            //   border: Border.all(
                            //     color: brightness == Brightness.dark
                            //         ? const Color(0x33FFFFFF)
                            //         : const Color(0x1A000000),
                            //     width: 1,
                            //   ),
                            // ),


                            decoration: BoxDecoration(
                              color: brightness == Brightness.dark
                                  ? Colors.black.withOpacity(0.1) // Fondo en modo oscuro
                                  : Colors.black.withOpacity(0.1), // Fondo en modo claro (puedes ajustar si es diferente)
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: brightness == Brightness.dark
                                    ? Colors.blueAccent[700]! // Color del borde en modo oscuro
                                    : Colors.orange, // Color del borde en modo claro
                                width: 1,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
                             child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.logout,
                                    color: brightness == Brightness.dark
                                        ? Colors.blueAccent[700]
                                         : Colors.orange,
                                    size: 24,
                                  ),
                                const  SizedBox(width: 12),
                                  Text(
                                    'Cerrar Sesión',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      color: brightness == Brightness.dark
                                         ? Colors.blueAccent[700]
                                         : Colors.orange,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),

                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Navegación
  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  // Construcción de secciones en grid
  Widget _buildGridSection(UserProvider userProvider,
      {required String title, required List<_GridItem> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.3,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return GestureDetector(
              onTap: item.onTap,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(item.icon, color: item.color, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      item.title,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _GridItem {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  _GridItem({
    required this.title,
    required this.icon,
    required this.color,
    this.onTap,
  });
}
