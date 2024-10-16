import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:zonix/features/utils/user_provider.dart';
import 'package:zonix/features/screens/profile_page.dart';
import 'package:zonix/features/DomainProfiles/Profiles/screens/profile_page.dart';
import 'package:zonix/features/screens/sign_in_screen.dart';


// Configuración del logger
final logger = Logger();



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
              _buildServiceSection(),
              const Divider(),
              _buildHelpAndLogoutSection(userProvider),
            ],
          ),
        ),
      ),
    );
  }
// Sección de Configuración General
Widget _buildGeneralSection() {
  return _SingleSection(
    title: "Configuración General",
    children: [
      // Perfil del usuario
      _CustomListTile(
        title: "Perfil",
        icon: Icons.person_outline_rounded, // Ícono de perfil
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              // builder: (context) => const ProfilePage1(),
               builder: (context) => const ProfilePagex(userId: 11),
            ),
          );
        },
      ),
      // Documentos asociados
      _CustomListTile(
        title: "Documentos",
        icon: Icons.folder_outlined, // Ícono de documentos
        onTap: () {
          logger.i("Documentos seleccionados");
        },
      ),
      // Dirección del usuario
      _CustomListTile(
        title: "Dirección",
        icon: Icons.location_on_outlined, // Ícono de ubicación
        onTap: () {
          logger.i("Dirección seleccionada");
        },
      ),
      // Carta de vecinos
      _CustomListTile(
        title: "Carta de vecinos",
        icon: Icons.groups_outlined, // Ícono para asociaciones/comunidad
        onTap: () {
          logger.i("Carta de vecinos seleccionada");
        },
      ),
      // Teléfonos de contacto
      _CustomListTile(
        title: "Teléfonos",
        icon: Icons.phone_outlined, // Ícono de teléfono
        onTap: () {
          logger.i("Teléfonos seleccionados");
        },
      ),
      // Correos electrónicos
      _CustomListTile(
        title: "Correos electrónicos",
        icon: Icons.email_outlined, // Ícono de correos electrónicos
        onTap: () {
          logger.i("Correos electrónicos seleccionados");
        },
      ),
    ],
  );
}

// Sección de Servicios
Widget _buildServiceSection() {
  return _SingleSection(
    title: "Servicios",
    children: [
      // Bombonas de gas disponibles
      _CustomListTile(
        title: "Bombonas de gas",
        icon: Icons.local_gas_station_outlined, // Ícono relacionado con gas
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProfilePage1(),
            ),
          );
        },
      ),
      // Tickets de gas
      _CustomListTile(
        title: "Tickets de gas",
        icon: Icons.receipt_long_outlined, // Ícono relacionado con tickets
        onTap: () {
          logger.i("Tickets de gas seleccionados");
        },
      ),
    ],
  );
}

// Sección de Ayuda y Cierre de Sesión
Widget _buildHelpAndLogoutSection(UserProvider userProvider) {
  return _SingleSection(
    title: "Administración y Seguridad",
    children: [
      // Notificaciones para el usuario
      _CustomListTile(
        title: "Notificaciones",
        icon: Icons.notifications_none_rounded, // Ícono de notificaciones
        onTap: () {
          logger.i("Notificaciones seleccionadas");
          // Agrega la lógica para notificaciones si es necesario
        },
      ),
      // Estado de seguridad del usuario
      _CustomListTile(
        title: "Estado de Seguridad",
        icon: Icons.shield_outlined, // Ícono de seguridad
        onTap: () {
          logger.i("Estado de Seguridad seleccionado");
          // Agrega la lógica para estado de seguridad si es necesario
        },
      ),
      // Ayuda y comentarios del usuario
      const _CustomListTile(
        title: "Ayuda y Comentarios",
        icon: Icons.help_outline_rounded, // Ícono de ayuda
      ),
      // Información acerca de la aplicación
      const _CustomListTile(
        title: "Acerca de",
        icon: Icons.info_outline_rounded, // Ícono de información
      ),
      // Cierre de sesión del usuario
      _CustomListTile(
        title: "Cerrar sesión",
        icon: Icons.logout_rounded, // Ícono específico para cerrar sesión
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
