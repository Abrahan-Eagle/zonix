import 'package:flutter/material.dart';
import 'package:zonix/features/DomainProfiles/Profiles/api/profile_service.dart';
import 'package:zonix/features/DomainProfiles/Profiles/models/profile_model.dart';
import 'package:zonix/features/DomainProfiles/Profiles/screens/edit_profile_page.dart';
import 'package:zonix/features/DomainProfiles/Profiles/screens/create_profile_page.dart';

class ProfilePagex extends StatefulWidget {
  final int userId;

  const ProfilePagex({super.key, required this.userId});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePagex> {
  Profile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      _profile = await ProfileService().getProfileById(widget.userId);
    } catch (e) {
      _profile = null;
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Perfil')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          const Expanded(flex: 2, child: _TopPortion()), // Encabezado visual
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(0.0),
              child: _profile != null ? _buildProfileDetails() : _buildNoProfile(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProfileField('Nombre', _profile!.firstName),
        _buildProfileField('Segundo Nombre', _profile!.middleName ?? 'N/A'),
        _buildProfileField('Apellido', _profile!.lastName),
        _buildProfileField('Segundo Apellido', _profile!.secondLastName ?? 'N/A'),
        _buildProfileField('Fecha de Nacimiento', _profile!.dateOfBirth ?? 'N/A'),
        _buildProfileField('Estado Civil', _profile!.maritalStatus ?? 'N/A'),
        _buildProfileField('Sexo', _profile!.sex),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton.extended(
              onPressed: () => _navigateToEditOrCreatePage(),
              label: _profile == null ? const Text('Crear Perfil') : const Text('Editar Perfil'),
              icon: _profile == null ? const Icon(Icons.person_add) : const Icon(Icons.edit),
            ),
          ],
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildNoProfile() {
    return const Center(
      child: Text(
        'No se encontró un perfil. Por favor, crea uno.',
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  void _navigateToEditOrCreatePage() {
    final route = _profile == null
        ? MaterialPageRoute(builder: (context) => CreateProfilePage(userId: widget.userId))
        : MaterialPageRoute(builder: (context) => EditProfilePage(userId: _profile!.userId));

    Navigator.push(context, route).then((_) => _loadProfile());
  }

  Widget _buildProfileField(String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0), // Espacio lateral
              alignment: Alignment.centerLeft,
              child: Text(
                '$etiqueta:',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0), // Espacio lateral
              alignment: Alignment.centerRight,
              child: Text(
                valor,
                style: const TextStyle(fontSize: 20),
                textAlign: TextAlign.end,
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
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 145),
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
          alignment: const Alignment(0, 0.4),
          child: SizedBox(
            width: 180,
            height: 180,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.white,
                      width: 6,
                    ),
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.black,
                    backgroundImage: _buildProfileImage(context),
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
  }

  ImageProvider<Object>? _buildProfileImage(BuildContext context) {
    final profile = context.findAncestorStateOfType<ProfilePageState>()?._profile;
    if (profile?.photo != null) {
      return NetworkImage(profile!.photo!);
    }
    return const AssetImage('assets/default_avatar.png');
  }
}
