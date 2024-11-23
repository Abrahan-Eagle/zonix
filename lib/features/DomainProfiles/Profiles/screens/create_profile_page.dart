import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:zonix/features/DomainProfiles/Profiles/api/profile_service.dart';
import 'package:zonix/features/DomainProfiles/Profiles/models/profile_model.dart';
import 'package:zonix/features/utils/user_provider.dart';
import 'package:image/image.dart' as img;


class CreateProfilePage extends StatefulWidget {
  final int userId;

  const CreateProfilePage({super.key, required this.userId});

  @override
  CreateProfilePageState createState() => CreateProfilePageState();
}

class CreateProfilePageState extends State<CreateProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late Profile _profile;
  final TextEditingController _dateController = TextEditingController();
  File? _imageFile; 
  final ImagePicker _picker = ImagePicker();

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
    );
  }

  @override
    void dispose() {
      _dateController.dispose();
      super.dispose();
    }

  // Future<void> _pickImage() async {
  //   final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
  //   if (pickedFile != null) {
  //     setState(() {
  //       _imageFile = File(pickedFile.path);
  //       _profile = _profile.copyWith(photo: _imageFile!.path);
  //     });
  //   }
  // }

  // Future<void> _takePhoto() async {
  //   final pickedFile = await _picker.pickImage(source: ImageSource.camera);
  //   if (pickedFile != null) {
  //     setState(() {
  //       _imageFile = File(pickedFile.path);
  //       _profile = _profile.copyWith(photo: _imageFile!.path);
  //     });
  //   }
  // }

 // Método para comprimir la imagen
  Future<File> compressImage(File imageFile) async {
    // Cargar la imagen
    img.Image image = img.decodeImage(imageFile.readAsBytesSync())!;

    // Intentamos reducir la calidad hasta 2MB
    int quality = 85;  // Comenzamos con una calidad del 85%
    int maxSize = 2 * 1024 * 1024; // 2MB en bytes

    // Comprimir y verificar el tamaño
    List<int> compressedImageBytes = img.encodeJpg(image, quality: quality);
    while (compressedImageBytes.length > maxSize && quality > 20) {
      quality -= 5;  // Reducir la calidad por 5 cada vez
      compressedImageBytes = img.encodeJpg(image, quality: quality);
    }

    // Guardar la imagen comprimida
    File compressedFile = await File(imageFile.path).writeAsBytes(compressedImageBytes);

    return compressedFile;
  }

//   // Método para tomar la foto
//   Future<void> _takePhoto() async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.camera);
//     if (pickedFile != null) {
//       // Comprimir la imagen después de tomarla
//       File compressedImage = await compressImage(File(pickedFile.path));

//       setState(() {
//         _imageFile = compressedImage;
//         _profile = _profile.copyWith(photo: _imageFile!.path);
//       });
//     }
//   }




// Future<File> compressImage(File imageFile) async {
//   try {
//     // Cargar la imagen
//     img.Image? image = img.decodeImage(await imageFile.readAsBytes());
//     if (image == null) {
//       throw Exception("No se pudo decodificar la imagen.");
//     }

//     // Establecer parámetros de compresión
//     int quality = 85;  // Calidad inicial
//     int maxSize = (1.5 * 1024 * 1024).toInt(); // 1.5 MB en bytes
//     List<int> compressedImageBytes = img.encodeJpg(image, quality: quality);

//     // Comprimir iterativamente hasta que el tamaño sea menor a 1.5 MB o alcanzar el límite de calidad
//     while (compressedImageBytes.length > maxSize && quality > 20) {
//       quality -= 5;  // Reducir la calidad por 5 cada vez
//       compressedImageBytes = img.encodeJpg(image, quality: quality);
//     }

//     // Si la calidad llega a 20 y no cumple con el tamaño deseado, simplemente comprimir con calidad mínima
//     if (compressedImageBytes.length > maxSize && quality <= 20) {
//       compressedImageBytes = img.encodeJpg(image, quality: 20);
//     }

//     // Guardar la imagen comprimida
//     final compressedFile = await File(imageFile.path)
//         .writeAsBytes(compressedImageBytes);
//     return compressedFile;
//   } catch (e) {
//     // Manejo de errores
//     print("Error al comprimir la imagen: $e");
//     rethrow;  // Lanza el error para que pueda ser manejado más arriba si es necesario
//   }
// }


// Método para tomar la foto
Future<void> _takePhoto() async {
  final pickedFile = await _picker.pickImage(source: ImageSource.camera);
  if (pickedFile != null) {
    // Comprimir la imagen después de tomarla
    File compressedImage = await compressImage(File(pickedFile.path));

    setState(() {
      _imageFile = compressedImage;
      _profile = _profile.copyWith(photo: _imageFile!.path);
    });
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
        _profile = _profile.copyWith(dateOfBirth: _dateController.text);
      });
    }
  }

  Future<void> _createProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        // Asegúrate de pasar correctamente el userId y la imagen.
        await ProfileService().createProfile(_profile, widget.userId, imageFile: _imageFile);

        // Actualiza el estado de `profileCreated` en `UserProvider` al crear el perfil con éxito
        context.read<UserProvider>().setProfileCreated(true);

        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al crear perfil: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Perfil')),
      body: SingleChildScrollView(
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
              // ElevatedButton(
              //   onPressed: _pickImage,
              //   child: const Text('Seleccionar Foto'),
              // ),

              ElevatedButton.icon(
                onPressed: _takePhoto,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Abrir Cámara'),
              ),

              if (_imageFile != null) ...[
                const SizedBox(height: 16),
                Image.file(_imageFile!, height: 150),
              ],
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
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Estado Civil'),
                items: const [
                  DropdownMenuItem(value: 'married', child: Text('Casado')),
                  DropdownMenuItem(value: 'divorced', child: Text('Divorciado')),
                  DropdownMenuItem(value: 'single', child: Text('Soltero')),
                ],
                validator: (value) => value == null ? 'Seleccione un estado civil' : null, // NUEVO
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _profile = _profile.copyWith(maritalStatus: value);
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Sexo'),
                items: const [
                  DropdownMenuItem(value: 'F', child: Text('Femenino')),
                  DropdownMenuItem(value: 'M', child: Text('Masculino')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _profile = _profile.copyWith(sex: value);
                    });
                  }
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _createProfile,
                child: const Text('Crear Perfil'),
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

// class CreateProfilePage extends StatefulWidget {
//   final int userId;

//   const CreateProfilePage({super.key, required this.userId});

//   @override
//   CreateProfilePageState createState() => CreateProfilePageState();
// }

// class CreateProfilePageState extends State<CreateProfilePage> {
//   final _formKey = GlobalKey<FormState>();
//   late Profile _profile;
//   final TextEditingController _dateController = TextEditingController();
//   File? _imageFile; 
//   final ImagePicker _picker = ImagePicker();

//   @override
//   void initState() {
//     super.initState();
//     _profile = Profile(
//       id: 0,
//       userId: widget.userId,
//       firstName: '',
//       middleName: '',
//       lastName: '',
//       secondLastName: '',
//       photo: null,
//       dateOfBirth: '',
//       maritalStatus: '',
//       sex: '',
//     );
//   }

//   Future<void> _pickImage() async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _imageFile = File(pickedFile.path);
//         _profile = _profile.copyWith(photo: _imageFile!.path);
//       });
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
//         _profile = _profile.copyWith(dateOfBirth: _dateController.text);
//       });
//     }
//   }

//   Future<void> _createProfile() async {
//     if (_formKey.currentState!.validate()) {
//       _formKey.currentState!.save();
//       try {
//         // Asegúrate de pasar correctamente el userId y la imagen.
//         await ProfileService().createProfile(_profile, widget.userId, imageFile: _imageFile);

//         if (mounted) {
//           Navigator.pop(context);
//         }
//       } catch (e) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Error al crear perfil: $e')),
//           );
//         }
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Crear Perfil')),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               TextFormField(
//                 decoration: const InputDecoration(labelText: 'Nombre'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Por favor, ingrese su nombre';
//                   }
//                   return null;
//                 },
//                 onSaved: (value) {
//                   if (value != null) {
//                     _profile = _profile.copyWith(firstName: value);
//                   }
//                 },
//               ),
//               TextFormField(
//                 decoration: const InputDecoration(labelText: 'Segundo Nombre'),
//                 onSaved: (value) {
//                   if (value != null) {
//                     _profile = _profile.copyWith(middleName: value);
//                   }
//                 },
//               ),
//               TextFormField(
//                 decoration: const InputDecoration(labelText: 'Apellido'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Por favor, ingrese su apellido';
//                   }
//                   return null;
//                 },
//                 onSaved: (value) {
//                   if (value != null) {
//                     _profile = _profile.copyWith(lastName: value);
//                   }
//                 },
//               ),
//               TextFormField(
//                 decoration: const InputDecoration(labelText: 'Segundo Apellido'),
//                 onSaved: (value) {
//                   if (value != null) {
//                     _profile = _profile.copyWith(secondLastName: value);
//                   }
//                 },
//               ),
//               ElevatedButton(
//                 onPressed: _pickImage,
//                 child: const Text('Seleccionar Foto'),
//               ),
//               if (_imageFile != null) ...[
//                 const SizedBox(height: 16),
//                 Image.file(_imageFile!, height: 150),
//               ],
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
//               DropdownButtonFormField<String>(
//                 decoration: const InputDecoration(labelText: 'Estado Civil'),
//                 items: const [
//                   DropdownMenuItem(value: 'married', child: Text('Casado')),
//                   DropdownMenuItem(value: 'divorced', child: Text('Divorciado')),
//                   DropdownMenuItem(value: 'single', child: Text('Soltero')),
//                 ],
//                 onChanged: (value) {
//                   if (value != null) {
//                     setState(() {
//                       _profile = _profile.copyWith(maritalStatus: value);
//                     });
//                   }
//                 },
//               ),
//               const SizedBox(height: 16),
//               DropdownButtonFormField<String>(
//                 decoration: const InputDecoration(labelText: 'Sexo'),
//                 items: const [
//                   DropdownMenuItem(value: 'F', child: Text('Femenino')),
//                   DropdownMenuItem(value: 'M', child: Text('Masculino')),
//                 ],
//                 onChanged: (value) {
//                   if (value != null) {
//                     setState(() {
//                       _profile = _profile.copyWith(sex: value);
//                     });
//                   }
//                 },
//               ),
//               const SizedBox(height: 24),
//               ElevatedButton(
//                 onPressed: _createProfile,
//                 child: const Text('Crear Perfil'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
