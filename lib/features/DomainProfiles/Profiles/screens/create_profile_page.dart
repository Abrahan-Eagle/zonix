import 'dart:io';
import 'package:flutter/material.dart';
import 'package:zonix/features/DomainProfiles/Profiles/api/profile_service.dart';
import 'package:zonix/features/DomainProfiles/Profiles/models/profile_model.dart';
import 'package:file_picker/file_picker.dart';

class CreateProfilePage extends StatefulWidget {
  final int userId;

  const CreateProfilePage({super.key, required this.userId});

  @override
  CreateProfilePageState createState() => CreateProfilePageState();
}

class CreateProfilePageState extends State<CreateProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late Profile _profile;

  @override
  void initState() {
    super.initState();
    _profile = Profile(
      id: 0,
      userId: widget.userId,
      firstName: '',
      middleName: '',
      lastName: '',
      secondLastName: '',
      photo: null,
      dateOfBirth: '',
      maritalStatus: '',
      sex: '',
      // status se genera automáticamente en el backend
    );
  }

  Future<void> _selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false, // Cambiar a true si necesitas múltiples archivos
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png'], // Agregar extensiones permitidas
    );

    if (result != null && result.files.isNotEmpty) {
      // Puedes almacenar la ruta del archivo aquí
      _profile = _profile.copyWith(photo: result.files.single.path);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _profile = _profile.copyWith(dateOfBirth: picked.toIso8601String());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Perfil')),
      body: SingleChildScrollView( // Agregar SingleChildScrollView para evitar el desbordamiento
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese su nombre';
                  }
                  return null;
                },
                onSaved: (value) {
                  if (value != null) {
                    _profile = _profile.copyWith(firstName: value);
                  }
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Segundo Nombre'),
                onSaved: (value) {
                  if (value != null) {
                    _profile = _profile.copyWith(middleName: value);
                  }
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Apellido'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese su apellido';
                  }
                  return null;
                },
                onSaved: (value) {
                  if (value != null) {
                    _profile = _profile.copyWith(lastName: value);
                  }
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Segundo Apellido'),
                onSaved: (value) {
                  if (value != null) {
                    _profile = _profile.copyWith(secondLastName: value);
                  }
                },
              ),
              ElevatedButton(
                onPressed: _selectFile,
                child: const Text('Seleccionar Foto'),
              ),
              TextFormField(
                readOnly: true, // Hacer el campo de fecha solo de lectura
                decoration: const InputDecoration(labelText: 'Fecha de Nacimiento'),
                onTap: () => _selectDate(context),
                controller: TextEditingController(text: _profile.dateOfBirth.isNotEmpty ? _profile.dateOfBirth : 'Seleccionar Fecha'),
              ),
              DropdownButtonFormField(
                decoration: const InputDecoration(labelText: 'Estado Civil'),
                items: const [
                  DropdownMenuItem(value: 'casado', child: Text('Casado')),
                  DropdownMenuItem(value: 'divorciado', child: Text('Divorciado')),
                  DropdownMenuItem(value: 'soltero', child: Text('Soltero')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    _profile = _profile.copyWith(maritalStatus: value);
                  }
                },
              ),
              DropdownButtonFormField(
                decoration: const InputDecoration(labelText: 'Sexo'),
                items: const [
                  DropdownMenuItem(value: 'F', child: Text('Femenino')),
                  DropdownMenuItem(value: 'M', child: Text('Masculino')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    _profile = _profile.copyWith(sex: value);
                  }
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    ProfileService().createProfile(_profile);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Crear Perfil'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
