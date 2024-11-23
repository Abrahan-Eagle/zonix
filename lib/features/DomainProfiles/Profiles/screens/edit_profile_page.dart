import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zonix/features/DomainProfiles/Profiles/api/profile_service.dart';
import 'package:zonix/features/DomainProfiles/Profiles/models/profile_model.dart';
import 'package:image/image.dart' as img;
class EditProfilePage extends StatefulWidget {
  final int userId;

  const EditProfilePage({super.key, required this.userId});

  @override
  EditProfilePageState createState() => EditProfilePageState();
}

class EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  Profile? _profile;
  final TextEditingController _dateController = TextEditingController();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    _profile = await ProfileService().getProfileById(widget.userId);
    if (_profile != null) {
      _dateController.text = _profile!.dateOfBirth;
      if (mounted) setState(() {});
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      _dateController.text = picked.toIso8601String().substring(0, 10);
      setState(() {
        _profile = _profile!.copyWith(dateOfBirth: _dateController.text);
      });
    }
  }

  // Future<void> _pickImage() async {
  //   final pickedFile = await _picker.pickImage(source: ImageSource.camera); // Aquí se usa la cámara
  //   if (pickedFile != null) {
  //     setState(() {
  //       _imageFile = File(pickedFile.path);
  //     });
  //   }
  // }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera); // Aquí se usa la cámara
    if (pickedFile != null) {
      String? compressedImagePath = await _compressImage(pickedFile.path);
      if (compressedImagePath != null) {
        setState(() {
          _imageFile = File(compressedImagePath); // Asignar el archivo comprimido
        });
      }
    }
  }


// Future<String?> _compressImage(String filePath) async {
//   try {
//     final imageFile = File(filePath);

//     // Verificar si la imagen ya es menor a 1.5  MG
//     if (await imageFile.length() <= 1.5 * 1024 * 1024) {
//       return filePath; // Devolver la misma imagen si no necesita compresión
//     }

//     final originalImage = img.decodeImage(await imageFile.readAsBytes());
//     if (originalImage == null) {
//       debugPrint("No se pudo decodificar la imagen.");
//       return null; // Si no se puede decodificar, devuelve null
//     }

//     String extension = filePath.split('.').last.toLowerCase();
//     int quality = 85; // Calidad inicial
//     List<int> compressedBytes;

//     if (extension == 'png') {
//       // Compresión para PNG
//       compressedBytes = img.encodePng(originalImage, level: 6);
//     } else {
//       // Compresión para JPG
//       compressedBytes = img.encodeJpg(originalImage, quality: quality);

//       // Reducir calidad iterativamente hasta que el tamaño sea menor a 1.5  MG (o 100 KB si lo deseas)
//       while (compressedBytes.length > 1.5 * 1024 * 1024 && quality > 10) {  // 1.5  MG
//         quality -= 5;
//         compressedBytes = img.encodeJpg(originalImage, quality: quality);
//       }
//     }

//     // Guardar la imagen comprimida
//     final compressedImageFile = await File(
//       '${imageFile.parent.path}/compressed_${imageFile.uri.pathSegments.last}',
//     ).writeAsBytes(compressedBytes);

//     debugPrint("Imagen comprimida guardada en: ${compressedImageFile.path}");
//     return compressedImageFile.path;

//   } catch (e) {
//     debugPrint("Error al comprimir la imagen: $e");
//     return null;
//   }
// }


// Future<String?> _compressImage(String filePath) async {
//   try {
//     final imageFile = File(filePath);

//     // Verificar si la imagen ya es menor a 1.5 MB
//     if (await imageFile.length() <= 1.5 * 1024 * 1024) {
//       return filePath; // Devolver la misma imagen si no necesita compresión
//     }

//     final originalImage = img.decodeImage(await imageFile.readAsBytes());
//     if (originalImage == null) {
//       debugPrint("No se pudo decodificar la imagen.");
//       return null; // Si no se puede decodificar, devuelve null
//     }

//     String extension = filePath.split('.').last.toLowerCase();
//     int quality = 85; // Calidad inicial
//     List<int> compressedBytes;

//     if (extension == 'png') {
//       // Compresión para PNG
//       compressedBytes = img.encodePng(originalImage, level: 6);
//     } else {
//       // Compresión para JPG
//       compressedBytes = img.encodeJpg(originalImage, quality: quality);

//       // Reducir calidad iterativamente hasta que el tamaño sea menor a 1.5 MB
//       while (compressedBytes.length > 1.5 * 1024 * 1024 && quality > 20) {  // Limitar la calidad mínima a 20
//         quality -= 5;
//         compressedBytes = img.encodeJpg(originalImage, quality: quality);
//       }
//     }

//     // Crear un nombre único para la imagen comprimida
//     final compressedImageFile = await File(
//       '${imageFile.parent.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.${extension}',
//     ).writeAsBytes(compressedBytes);

//     debugPrint("Imagen comprimida guardada en: ${compressedImageFile.path}");
//     return compressedImageFile.path;

//   } catch (e) {
//     debugPrint("Error al comprimir la imagen: $e");
//     return null;
//   }
// }



 Future<String?> _compressImage(String filePath) async {
    try {
      final imageFile = File(filePath);

      // Verificar si la imagen ya es menor a 2 MB
      if (await imageFile.length() <= 2 * 1024 * 1024) {
        return filePath; // Devolver la misma imagen si no necesita compresión
      }

      final originalImage = img.decodeImage(await imageFile.readAsBytes());
      if (originalImage == null) {
        debugPrint("No se pudo decodificar la imagen.");
        return null; // Si no se puede decodificar, devuelve null
      }

      String extension = filePath.split('.').last.toLowerCase();
      int quality = 85; // Calidad inicial
      List<int> compressedBytes;

      if (extension == 'png') {
        // Compresión para PNG
        compressedBytes = img.encodePng(originalImage, level: 6);
      } else {
        // Compresión para JPG
        compressedBytes = img.encodeJpg(originalImage, quality: quality);

        // Reducir calidad iterativamente si es mayor a 2 MB
        while (compressedBytes.length > 2 * 1024 * 1024 && quality > 10) {
          quality -= 5;
          compressedBytes = img.encodeJpg(originalImage, quality: quality);
        }
      }

      // Guardar la imagen comprimida
      final compressedImageFile = await File(
        '${imageFile.parent.path}/compressed_${imageFile.uri.pathSegments.last}',
      ).writeAsBytes(compressedBytes);

      debugPrint("Imagen comprimida guardada en: ${compressedImageFile.path}");
      return compressedImageFile.path;

    } catch (e) {
      debugPrint("Error al comprimir la imagen: $e");
      return null;
    }
  }
  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        await ProfileService().updateProfile(
          _profile!.id,
          _profile!,
          imageFile: _imageFile,
        );

        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al actualizar perfil: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_profile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Editar Perfil')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Editar Perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _profile!.firstName,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) => value == null || value.isEmpty ? 'Ingrese su nombre' : null,
                onSaved: (value) {
                  if (value != null) {
                    _profile = _profile!.copyWith(firstName: value);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _profile!.middleName,
                decoration: const InputDecoration(labelText: 'Segundo Nombre'),
                onSaved: (value) {
                  if (value != null) {
                    _profile = _profile!.copyWith(middleName: value);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _profile!.lastName,
                decoration: const InputDecoration(labelText: 'Apellido'),
                validator: (value) => value == null || value.isEmpty ? 'Ingrese su apellido' : null,
                onSaved: (value) {
                  if (value != null) {
                    _profile = _profile!.copyWith(lastName: value);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _profile!.secondLastName,
                decoration: const InputDecoration(labelText: 'Segundo Apellido'),
                onSaved: (value) {
                  if (value != null) {
                    _profile = _profile!.copyWith(secondLastName: value);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: 'Fecha de Nacimiento',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _pickDate(context),
                  ),
                ),
                readOnly: true,
                validator: (value) => value == null || value.isEmpty ? 'Seleccione una fecha' : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Tomar Foto'),
              ),
              if (_imageFile != null) ...[
                const SizedBox(height: 16),
                Image.file(_imageFile!, height: 150),
              ],
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _profile!.maritalStatus,
                decoration: const InputDecoration(labelText: 'Estado Civil'),
                items: const [
                  DropdownMenuItem(value: 'married', child: Text('Casado')),
                  DropdownMenuItem(value: 'divorced', child: Text('Divorciado')),
                  DropdownMenuItem(value: 'single', child: Text('Soltero')),
                ],
                onChanged: (value) {
                  setState(() {
                    _profile = _profile!.copyWith(maritalStatus: value);
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _profile!.sex,
                decoration: const InputDecoration(labelText: 'Sexo'),
                items: const [
                  DropdownMenuItem(value: 'F', child: Text('Femenino')),
                  DropdownMenuItem(value: 'M', child: Text('Masculino')),
                ],
                onChanged: (value) {
                  setState(() {
                    _profile = _profile!.copyWith(sex: value);
                  });
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _updateProfile,
                child: const Text('Guardar Cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}




// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:zonix/features/DomainProfiles/Profiles/api/profile_service.dart';
// import 'package:zonix/features/DomainProfiles/Profiles/models/profile_model.dart';

// class EditProfilePage extends StatefulWidget {
//   final int userId;

//   const EditProfilePage({super.key, required this.userId});

//   @override
//   EditProfilePageState createState() => EditProfilePageState();
// }

// class EditProfilePageState extends State<EditProfilePage> {
//   final _formKey = GlobalKey<FormState>();
//   Profile? _profile;
//   final TextEditingController _dateController = TextEditingController();
//   File? _imageFile; 
//   final ImagePicker _picker = ImagePicker();

//   @override
//   void initState() {
//     super.initState();
//     _loadProfile();
//   }

//   Future<void> _loadProfile() async {
//     _profile = await ProfileService().getProfileById(widget.userId);
//     if (_profile != null) {
//       _dateController.text = _profile!.dateOfBirth; 
//       if (mounted) setState(() {});
//     }
//   }

//   Future<void> _pickDate(BuildContext context) async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(1900),
//       lastDate: DateTime.now(),
//     );

//     if (picked != null) {
//       _dateController.text = picked.toIso8601String().substring(0, 10);
//       setState(() {
//         _profile = _profile!.copyWith(dateOfBirth: _dateController.text);
//       });
//     }
//   }

//   Future<void> _pickImage() async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _imageFile = File(pickedFile.path);
//       });
//     }
//   }

//   Future<void> _updateProfile() async {
//     if (_formKey.currentState!.validate()) {
//       _formKey.currentState!.save();
//       try {
//         await ProfileService().updateProfile(
//           _profile!.id,
//           _profile!,
//           imageFile: _imageFile, 
//         );

//         if (mounted) {
//           Navigator.pop(context);
//         }
//       } catch (e) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Error al actualizar perfil: $e')),
//           );
//         }
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_profile == null) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Editar Perfil')),
//         body: const Center(child: CircularProgressIndicator()),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(title: const Text('Editar Perfil')),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               TextFormField(
//                 initialValue: _profile!.firstName,
//                 decoration: const InputDecoration(labelText: 'Nombre'),
//                 validator: (value) => value == null || value.isEmpty ? 'Ingrese su nombre' : null,
//                 onSaved: (value) {
//                   if (value != null) {
//                     _profile = _profile!.copyWith(firstName: value);
//                   }
//                 },
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 initialValue: _profile!.middleName,
//                 decoration: const InputDecoration(labelText: 'Segundo Nombre'),
//                 onSaved: (value) {
//                   if (value != null) {
//                     _profile = _profile!.copyWith(middleName: value);
//                   }
//                 },
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 initialValue: _profile!.lastName,
//                 decoration: const InputDecoration(labelText: 'Apellido'),
//                 validator: (value) => value == null || value.isEmpty ? 'Ingrese su apellido' : null,
//                 onSaved: (value) {
//                   if (value != null) {
//                     _profile = _profile!.copyWith(lastName: value);
//                   }
//                 },
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 initialValue: _profile!.secondLastName,
//                 decoration: const InputDecoration(labelText: 'Segundo Apellido'),
//                 onSaved: (value) {
//                   if (value != null) {
//                     _profile = _profile!.copyWith(secondLastName: value);
//                   }
//                 },
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _dateController,
//                 decoration: InputDecoration(
//                   labelText: 'Fecha de Nacimiento',
//                   suffixIcon: IconButton(
//                     icon: const Icon(Icons.calendar_today),
//                     onPressed: () => _pickDate(context),
//                   ),
//                 ),
//                 readOnly: true,
//                 validator: (value) => value == null || value.isEmpty ? 'Seleccione una fecha' : null,
//               ),
//               const SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: _pickImage,
//                 child: const Text('Seleccionar Foto'),
//               ),
//               if (_imageFile != null) ...[
//                 const SizedBox(height: 16),
//                 Image.file(_imageFile!, height: 150),
//               ],
//               const SizedBox(height: 16),
//               DropdownButtonFormField<String>(
//                 value: _profile!.maritalStatus,
//                 decoration: const InputDecoration(labelText: 'Estado Civil'),
//                 items: const [
//                   DropdownMenuItem(value: 'married', child: Text('Casado')),
//                   DropdownMenuItem(value: 'divorced', child: Text('Divorciado')),
//                   DropdownMenuItem(value: 'single', child: Text('Soltero')),
//                 ],
//                 onChanged: (value) {
//                   setState(() {
//                     _profile = _profile!.copyWith(maritalStatus: value);
//                   });
//                 },
//               ),
//               const SizedBox(height: 16),
//               DropdownButtonFormField<String>(
//                 value: _profile!.sex,
//                 decoration: const InputDecoration(labelText: 'Sexo'),
//                 items: const [
//                   DropdownMenuItem(value: 'F', child: Text('Femenino')),
//                   DropdownMenuItem(value: 'M', child: Text('Masculino')),
//                 ],
//                 onChanged: (value) {
//                   setState(() {
//                     _profile = _profile!.copyWith(sex: value);
//                   });
//                 },
//               ),
//               const SizedBox(height: 24),
//               ElevatedButton(
//                 onPressed: _updateProfile,
//                 child: const Text('Guardar Cambios'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
