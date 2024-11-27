
import 'dart:io';
// import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Google ML Kit Face Detection',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text('Face Recognition Example')),
        body: const FaceDetectionExample(),
      ),
    );
  }
}

class FaceDetectionExample extends StatefulWidget {
  const FaceDetectionExample({super.key});

  @override
  FaceDetectionExampleState createState() => FaceDetectionExampleState();
}

class FaceDetectionExampleState extends State<FaceDetectionExample> {
  File? _imageFile;
  String _mlResult = 'No faces detected yet.';
  final _picker = ImagePicker();
  bool _isDetecting = false; // Track the detection process

  // Function to pick an image from the camera
  Future<bool> _pickImage(ImageSource source) async {
    setState(() {
      _imageFile = null;
      _mlResult = 'No faces detected yet.';
    });

    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please take or select a picture first.')),
      );
      return false;
    }

    setState(() => _imageFile = File(pickedFile.path));
    return true;
  }

  // Face detection function with error handling
  Future<void> _faceDetect() async {
    if (_isDetecting) return; // Prevent simultaneous detections
    setState(() {
      _isDetecting = true;
      _mlResult = 'Detecting faces...';
    });

    try {
      if (await _pickImage(ImageSource.camera) == false) {
        setState(() => _isDetecting = false);
        return;
      }

      String result = '';
      final InputImage inputImage = InputImage.fromFile(_imageFile!);

      final options = FaceDetectorOptions(
        enableLandmarks: true,
        enableClassification: true,
        enableTracking: true,
      );
      final FaceDetector faceDetector = FaceDetector(options: options);

      final List<Face> faces = await faceDetector.processImage(inputImage);
      result += 'Detected ${faces.length} face(s).\n';

      // Store the face features for later comparison
      List<List<double>> faceFeatures = [];

      for (final Face face in faces) {
        final Rect boundingBox = face.boundingBox;
        final double? rotY = face.headEulerAngleY;
        final double? rotZ = face.headEulerAngleZ;
        result += '\n# Face:\n '
            'bbox=$boundingBox\n '
            'rotY=${rotY?.toStringAsFixed(2)}\n '
            'rotZ=${rotZ?.toStringAsFixed(2)}\n ';
        
        if (face.smilingProbability != null) {
          final double smileProb = face.smilingProbability!;
          result += 'smileProb=${smileProb.toStringAsFixed(3)}\n ';
        }

        // Extract facial features like landmarks
        if (face.landmarks != null) {
          final List<double> featureVector = [];
          featureVector.addAll([face.headEulerAngleY ?? 0, face.headEulerAngleZ ?? 0]);
          // You can extract more features here like landmarks or classifications if needed
          faceFeatures.add(featureVector);
        }

        if (face.trackingId != null) {
          final int id = face.trackingId!;
          result += 'id=$id\n ';
        }
      }

      faceDetector.close();

      // Here you can send `faceFeatures` to your server to store it in the database for future comparisons

      setState(() {
        _mlResult = result.isNotEmpty ? result : 'No faces detected.';
      });

      // Save features to a file or a local storage for comparison
      // You can use the features (like `faceFeatures`) to compare faces in the future
      print('Extracted face features: $faceFeatures');

    } catch (e) {
      setState(() {
        _mlResult = 'Error during face detection: $e';
      });
    } finally {
      setState(() => _isDetecting = false); // Ensure the flag is reset
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        if (_imageFile == null)
          const Placeholder(
            fallbackHeight: 200.0,
          )
        else
          Image.file(_imageFile!),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: OverflowBar(
            children: <Widget>[
              ElevatedButton(
                onPressed: _isDetecting ? null : _faceDetect,
                child: Text(_isDetecting ? 'Detecting...' : 'Detect Faces'),
              ),
            ],
          ),
        ),
        const Divider(),
        Text('Result:', style: Theme.of(context).textTheme.titleSmall),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Text(
            _mlResult,
            style: const TextStyle(fontFamily: 'Courier'),
          ),
        ),
      ],
    );
  }
}



// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:image/image.dart' as img;

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Google ML Kit Face Detection',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: const FaceDetectionExample(),
//     );
//   }
// }

// class FaceDetectionExample extends StatefulWidget {
//   const FaceDetectionExample({super.key});

//   @override
//   FaceDetectionExampleState createState() => FaceDetectionExampleState();
// }

// class FaceDetectionExampleState extends State<FaceDetectionExample> {
//   File? _imageFile;
//   String _mlResult = 'Capture an image to start.';
//   final _picker = ImagePicker();
//   bool _isDetecting = false;

//   Future<void> _pickImage(ImageSource source) async {
//     final XFile? pickedFile = await _picker.pickImage(source: source);
//     if (pickedFile != null) {
//       setState(() => _imageFile = File(pickedFile.path));
//       await _faceDetect(); // Llama automáticamente a la detección facial
//     } else {
//       setState(() {
//         _imageFile = null;
//         _mlResult = 'No image selected.';
//       });
//     }
//   }

//   Future<void> _faceDetect() async {
//     if (_isDetecting || _imageFile == null) return;

//     setState(() {
//       _isDetecting = true;
//       _mlResult = 'Detecting faces...';
//     });

//     try {
//       final img.Image image = img.decodeImage(_imageFile!.readAsBytesSync())!;
//       final double imageWidth = image.width.toDouble();
//       final double imageHeight = image.height.toDouble();

//       final inputImage = InputImage.fromFile(_imageFile!);
//       final faceDetector = FaceDetector(
//         options: FaceDetectorOptions(
//           enableLandmarks: true,
//           enableClassification: true,
//           enableTracking: true,
//         ),
//       );

//       final faces = await faceDetector.processImage(inputImage);
//       await faceDetector.close();

//       if (faces.isEmpty) {
//         setState(() {
//           _mlResult = 'No faces detected.';
//           _isDetecting = false;
//         });
//         return;
//       }

//       final faceFeatures = faces.map((face) {
//         final landmarks = face.landmarks;
//         return {
//           'leftEyeX': ((landmarks[FaceLandmarkType.leftEye]?.position.x ?? 0) /
//               imageWidth),
//           'leftEyeY': ((landmarks[FaceLandmarkType.leftEye]?.position.y ?? 0) /
//               imageHeight),
//           'rightEyeX':
//               ((landmarks[FaceLandmarkType.rightEye]?.position.x ?? 0) /
//                   imageWidth),
//           'rightEyeY':
//               ((landmarks[FaceLandmarkType.rightEye]?.position.y ?? 0) /
//                   imageHeight),
//           'noseX': ((landmarks[FaceLandmarkType.noseBase]?.position.x ?? 0) /
//               imageWidth),
//           'noseY': ((landmarks[FaceLandmarkType.noseBase]?.position.y ?? 0) /
//               imageHeight),
//         };
//       }).toList();

//       final isMatch = await _compareFaceFeatures(faceFeatures);

//       setState(() {
//         _mlResult = isMatch
//             ? 'Face matched with stored data.'
//             : 'Face does not match stored data. New face stored.';
//       });

//       if (!isMatch) {
//         await _storeFaceFeatures(faceFeatures);
//       }
//     } catch (e) {
//       setState(() {
//         _mlResult = 'Error during face detection: $e';
//       });
//     } finally {
//       setState(() => _isDetecting = false);
//     }
//   }

//   Future<void> _storeFaceFeatures(List<Map<String, double>> features) async {
//     final prefs = await SharedPreferences.getInstance();
//     final storedFeatures = prefs.getStringList('storedFaceFeatures') ?? [];
//     storedFeatures.add(jsonEncode(features));
//     await prefs.setStringList('storedFaceFeatures', storedFeatures);
//     print('Face features stored: ${jsonEncode(features)}');
//   }

//   Future<bool> _compareFaceFeatures(List<Map<String, double>> features) async {
//     final prefs = await SharedPreferences.getInstance();
//     final storedData = prefs.getStringList('storedFaceFeatures');

//     if (storedData == null || storedData.isEmpty) {
//       return false;
//     }

//     final List<List<Map<String, double>>> storedFeatures = storedData
//         .map((data) =>
//             List<Map<String, dynamic>>.from(jsonDecode(data)).map((map) {
//               return map.map(
//                 (key, value) => MapEntry(key, (value as num).toDouble()),
//               );
//             }).toList())
//         .toList();

//     const double marginOfError = 0.07; // Ajuste para distancias variables

//     for (final storedList in storedFeatures) {
//       for (final stored in storedList) {
//         for (final detected in features) {
//           final isMatch = stored.entries.every((entry) {
//             final storedValue = entry.value;
//             final detectedValue = detected[entry.key]!;
//             return (storedValue - detectedValue).abs() <= marginOfError;
//           });
//           if (isMatch) return true;
//         }
//       }
//     }

//     return false;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Face Detection')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             if (_imageFile != null)
//               Image.file(
//                 _imageFile!,
//                 height: 300,
//                 width: 300,
//                 fit: BoxFit.cover,
//               ),
//             const SizedBox(height: 20),
//             Text(_mlResult, style: const TextStyle(fontSize: 20)),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => _pickImage(ImageSource.camera),
//         tooltip: 'Capture Face',
//         child: const Icon(Icons.camera_alt),
//       ),
//     );
//   }
// }












// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:image/image.dart' as img;

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Google ML Kit Face Detection',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: const FaceDetectionExample(),
//     );
//   }
// }

// class FaceDetectionExample extends StatefulWidget {
//   const FaceDetectionExample({super.key});

//   @override
//   FaceDetectionExampleState createState() => FaceDetectionExampleState();
// }

// class FaceDetectionExampleState extends State<FaceDetectionExample> {
//   File? _imageFile;
//   String _mlResult = 'Capture an image to start.';
//   final _picker = ImagePicker();
//   bool _isDetecting = false;

//   Future<void> _pickImage(ImageSource source) async {
//     final XFile? pickedFile = await _picker.pickImage(source: source);
//     if (pickedFile != null) {
//       setState(() => _imageFile = File(pickedFile.path));
//       await _faceDetect(); // Llama automáticamente a la detección facial
//     } else {
//       setState(() {
//         _imageFile = null;
//         _mlResult = 'No image selected.';
//       });
//     }
//   }

//   Future<void> _faceDetect() async {
//     if (_isDetecting || _imageFile == null) return;

//     setState(() {
//       _isDetecting = true;
//       _mlResult = 'Detecting faces...';
//     });

//     try {
//       final img.Image image = img.decodeImage(_imageFile!.readAsBytesSync())!;
//       final double imageWidth = image.width.toDouble();
//       final double imageHeight = image.height.toDouble();

//       final inputImage = InputImage.fromFile(_imageFile!);
//       final faceDetector = FaceDetector(
//         options: FaceDetectorOptions(
//           enableLandmarks: true,
//           enableClassification: true,
//           enableTracking: true,
//         ),
//       );

//       final faces = await faceDetector.processImage(inputImage);
//       await faceDetector.close();

//       if (faces.isEmpty) {
//         setState(() {
//           _mlResult = 'No faces detected.';
//           _isDetecting = false;
//         });
//         return;
//       }

//       final faceFeatures = faces.map((face) {
//         final landmarks = face.landmarks;
//         return {
//           'leftEyeX': ((landmarks[FaceLandmarkType.leftEye]?.position.x ?? 0) /
//               imageWidth),
//           'leftEyeY': ((landmarks[FaceLandmarkType.leftEye]?.position.y ?? 0) /
//               imageHeight),
//           'rightEyeX':
//               ((landmarks[FaceLandmarkType.rightEye]?.position.x ?? 0) /
//                   imageWidth),
//           'rightEyeY':
//               ((landmarks[FaceLandmarkType.rightEye]?.position.y ?? 0) /
//                   imageHeight),
//           'noseX': ((landmarks[FaceLandmarkType.noseBase]?.position.x ?? 0) /
//               imageWidth),
//           'noseY': ((landmarks[FaceLandmarkType.noseBase]?.position.y ?? 0) /
//               imageHeight),
//         };
//       }).toList();

//       final isMatch = await _compareFaceFeatures(faceFeatures);

//       setState(() {
//         _mlResult = isMatch
//             ? 'Face matched with stored data.'
//             : 'Face does not match stored data. New face stored.';
//       });

//       if (!isMatch) {
//         await _storeFaceFeatures(faceFeatures);
//       }
//     } catch (e) {
//       setState(() {
//         _mlResult = 'Error during face detection: $e';
//       });
//     } finally {
//       setState(() => _isDetecting = false);
//     }
//   }

//   Future<void> _storeFaceFeatures(List<Map<String, double>> features) async {
//     final prefs = await SharedPreferences.getInstance();
//     final storedFeatures = prefs.getStringList('storedFaceFeatures') ?? [];
//     storedFeatures.add(jsonEncode(features));
//     await prefs.setStringList('storedFaceFeatures', storedFeatures);
//     print('Face features stored: ${jsonEncode(features)}');
//   }

//   Future<bool> _compareFaceFeatures(List<Map<String, double>> features) async {
//     final prefs = await SharedPreferences.getInstance();
//     final storedData = prefs.getStringList('storedFaceFeatures');

//     if (storedData == null || storedData.isEmpty) {
//       return false;
//     }

//     final List<List<Map<String, double>>> storedFeatures = storedData
//         .map((data) =>
//             List<Map<String, dynamic>>.from(jsonDecode(data)).map((map) {
//               return map.map(
//                 (key, value) => MapEntry(key, (value as num).toDouble()),
//               );
//             }).toList())
//         .toList();

//     const double marginOfError = 0.07; // Ajuste para distancias variables

//     for (final storedList in storedFeatures) {
//       for (final stored in storedList) {
//         for (final detected in features) {
//           final isMatch = stored.entries.every((entry) {
//             final storedValue = entry.value;
//             final detectedValue = detected[entry.key]!;
//             return (storedValue - detectedValue).abs() <= marginOfError;
//           });
//           if (isMatch) return true;
//         }
//       }
//     }

//     return false;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Face Detection')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             if (_imageFile != null)
//               Image.file(
//                 _imageFile!,
//                 height: 300,
//                 width: 300,
//                 fit: BoxFit.cover,
//               ),
//             const SizedBox(height: 20),
//             Text(_mlResult, style: const TextStyle(fontSize: 20)),
//             if (_isDetecting) const CircularProgressIndicator(),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => _pickImage(ImageSource.camera),
//         child: const Icon(Icons.camera),
//       ),
//     );
//   }
// }

































// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Google ML Kit Face Detection',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const FaceDetectionExample(),
//     );
//   }
// }

// class FaceDetectionExample extends StatefulWidget {
//   const FaceDetectionExample({super.key});

//   @override
//   FaceDetectionExampleState createState() => FaceDetectionExampleState();
// }

// class FaceDetectionExampleState extends State<FaceDetectionExample> {
//   File? _imageFile;
//   String _mlResult = 'No faces detected yet.';
//   final _picker = ImagePicker();
//   bool _isDetecting = false;
//   List<Map<String, double>> _detectedFeatures = [];
//   List<Map<String, double>> _storedFeatures = [];

//   Future<bool> _pickImage(ImageSource source) async {
//     setState(() {
//       _imageFile = null;
//       _mlResult = 'No faces detected yet.';
//     });

//     final XFile? pickedFile = await _picker.pickImage(source: source);

//     if (pickedFile == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please take or select a picture first.')),
//       );
//       return false;
//     }

//     setState(() => _imageFile = File(pickedFile.path));
//     return true;
//   }

//   Future<void> _faceDetect() async {
//     if (_isDetecting) return;
//     setState(() {
//       _isDetecting = true;
//       _mlResult = 'Detecting faces...';
//       _detectedFeatures = [];
//     });

//     try {
//       if (await _pickImage(ImageSource.camera) == false) {
//         setState(() => _isDetecting = false);
//         return;
//       }

//       final inputImage = InputImage.fromFile(_imageFile!);
//       final options = FaceDetectorOptions(
//         enableLandmarks: true,
//         enableClassification: true,
//         enableTracking: true,
//       );
//       final faceDetector = FaceDetector(options: options);

//       final faces = await faceDetector.processImage(inputImage);
//       faceDetector.close();

//       if (faces.isEmpty) {
//         setState(() {
//           _mlResult = 'No faces detected.';
//           _isDetecting = false;
//         });
//         return;
//       }

//       final faceFeatures = faces.map((face) {
//         return {
//           'rotY': face.headEulerAngleY ?? 0.0,
//           'rotZ': face.headEulerAngleZ ?? 0.0,
//         };
//       }).toList();

//       setState(() => _detectedFeatures = faceFeatures);

//       final isMatch = await _compareFaceFeatures(faceFeatures);

//       setState(() {
//         _mlResult = isMatch
//             ? 'Face matched with stored data.'
//             : 'Face does not match stored data.';
//       });

//       if (!isMatch) {
//         await _storeFaceFeatures(faceFeatures);
//       }
//     } catch (e) {
//       setState(() {
//         _mlResult = 'Error during face detection: $e';
//       });
//     } finally {
//       setState(() => _isDetecting = false);
//     }
//   }

//   Future<void> _storeFaceFeatures(List<Map<String, double>> features) async {
//     final prefs = await SharedPreferences.getInstance();
//     final encodedFeatures = jsonEncode(features);
//     await prefs.setString('storedFaceFeatures', encodedFeatures);
//     print('Face features stored: $encodedFeatures');
//   }

//   Future<bool> _compareFaceFeatures(List<Map<String, double>> features) async {
//     final prefs = await SharedPreferences.getInstance();
//     final storedData = prefs.getString('storedFaceFeatures');

//     if (storedData == null) {
//       return false;
//     }

//     final storedFeatures = List<Map<String, dynamic>>.from(jsonDecode(storedData))
//         .map((map) => map.map((key, value) => MapEntry(key, value as double)))
//         .toList();

//     setState(() => _storedFeatures = storedFeatures);

//     for (final stored in storedFeatures) {
//       for (final detected in features) {
//         if ((stored['rotY']! - detected['rotY']!).abs() < 5 &&

//             (stored['rotZ']! - detected['rotZ']!).abs() < 5) {
//           return true;
//         }
//       }
//     }

//     return false;
//   }

// Widget _buildFeatureTable(String title, List<Map<String, double>> features) {
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Text(
//         title,
//         style: const TextStyle(fontWeight: FontWeight.bold),
//       ),
//       ...features.map((feature) {
//         return Text('rotY: ${feature['rotY']}, rotZ: ${feature['rotZ']}');
//       }),
//       const Divider(),
//     ],
//   );
// }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Face Recognition Example')),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           if (_imageFile == null)
//             const Placeholder(fallbackHeight: 200.0)
//           else
//             Image.file(_imageFile!),
//           ElevatedButton(
//             onPressed: _isDetecting ? null : _faceDetect,
//             child: Text(_isDetecting ? 'Detecting...' : 'Detect Face'),
//           ),
//           const Divider(),
//           Text(
//             'Result:',
//             style: Theme.of(context).textTheme.titleSmall,
//           ),
//           Text(
//             _mlResult,
//             style: const TextStyle(fontFamily: 'Courier'),
//           ),
//           const Divider(),
//           _buildFeatureTable('Detected Features:', _detectedFeatures),
//           _buildFeatureTable('Stored Features:', _storedFeatures),
//         ],
//       ),
//     );
//   }
// }




// codigo seguro
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Google ML Kit Face Detection',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const FaceDetectionExample(),
//     );
//   }
// }

// class FaceDetectionExample extends StatefulWidget {
//   const FaceDetectionExample({super.key});

//   @override
//   FaceDetectionExampleState createState() => FaceDetectionExampleState();
// }

// class FaceDetectionExampleState extends State<FaceDetectionExample> {
//   File? _imageFile;
//   String _mlResult = 'No faces detected yet.';
//   final _picker = ImagePicker();
//   bool _isDetecting = false;

//   Future<bool> _pickImage(ImageSource source) async {
//     final XFile? pickedFile = await _picker.pickImage(source: source);

//     if (pickedFile == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please take or select a picture first.')),
//       );
//       return false;
//     }

//     setState(() => _imageFile = File(pickedFile.path));
//     return true;
//   }

//   Future<void> _faceDetect() async {
//     if (_isDetecting) return;
//     setState(() {
//       _isDetecting = true;
//       _mlResult = 'Detecting faces...';
//     });

//     try {
//       if (await _pickImage(ImageSource.camera) == false) {
//         setState(() => _isDetecting = false);
//         return;
//       }

//       final inputImage = InputImage.fromFile(_imageFile!);
//       final options = FaceDetectorOptions(
//         enableLandmarks: true,
//         enableClassification: true,
//         enableTracking: true,
//       );
//       final faceDetector = FaceDetector(options: options);

//       final faces = await faceDetector.processImage(inputImage);

//       if (faces.isEmpty) {
//         setState(() {
//           _mlResult = 'No faces detected.';
//           _isDetecting = false;
//         });
//         return;
//       }

//       final faceFeatures = faces.map((face) {
//         return {
//           'rotY': face.headEulerAngleY ?? 0.0,
//           'rotZ': face.headEulerAngleZ ?? 0.0,
//         };
//       }).toList();

//       final isMatch = await _compareFaceFeatures(faceFeatures);

//       setState(() {
//         _mlResult = isMatch
//             ? 'Face matched with stored data.'
//             : 'Face does not match stored data.';
//       });

//       if (!isMatch) {
//         await _storeFaceFeatures(faceFeatures);
//       }
//     } catch (e) {
//       setState(() {
//         _mlResult = 'Error during face detection: $e';
//       });
//     } finally {
//       setState(() => _isDetecting = false);
//     }
//   }

//   Future<void> _storeFaceFeatures(List<Map<String, double>> features) async {
//     final prefs = await SharedPreferences.getInstance();
//     final encodedFeatures = jsonEncode(features);
//     await prefs.setString('storedFaceFeatures', encodedFeatures);
//     print('Face features stored: $encodedFeatures');
//   }

//   Future<bool> _compareFaceFeatures(List<Map<String, double>> features) async {
//     final prefs = await SharedPreferences.getInstance();
//     final storedData = prefs.getString('storedFaceFeatures');

//     if (storedData == null) {
//       return false;
//     }

//     // Decode and cast the stored data into List<Map<String, double>>
//     final storedFeatures = List<Map<String, dynamic>>.from(jsonDecode(storedData))
//         .map((map) => map.map((key, value) => MapEntry(key, value as double)))
//         .toList();

//     for (final stored in storedFeatures) {
//       for (final detected in features) {
//         if ((stored['rotY']! - detected['rotY']!).abs() < 5 &&
//             (stored['rotZ']! - detected['rotZ']!).abs() < 5) {
//           return true;
//         }
//       }
//     }

//     return false;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Face Recognition Example')),
//       body: ListView(
//         children: [
//           if (_imageFile == null)
//             const Placeholder(fallbackHeight: 200.0)
//           else
//             Image.file(_imageFile!),
//           ElevatedButton(
//             onPressed: _isDetecting ? null : _faceDetect,
//             child: Text(_isDetecting ? 'Detecting...' : 'Detect Face'),
//           ),
//           const Divider(),
//           Text(
//             'Result:',
//             style: Theme.of(context).textTheme.titleSmall,
//           ),
//           Text(
//             _mlResult,
//             style: const TextStyle(fontFamily: 'Courier'),
//           ),
//         ],
//       ),
//     );
//   }
// }






















// // // // import 'dart:io';
// // // // import 'dart:typed_data';
// // // // import 'package:flutter/material.dart';
// // // // import 'package:image_picker/image_picker.dart';
// // // // import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

// // // // void main() {
// // // //   runApp(const MyApp());
// // // // }

// // // // class MyApp extends StatelessWidget {
// // // //   const MyApp({super.key});

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return MaterialApp(
// // // //       debugShowCheckedModeBanner: false,
// // // //       title: 'Google ML Kit Example',
// // // //       theme: ThemeData(
// // // //         primarySwatch: Colors.blue,
// // // //       ),
// // // //       home: Scaffold(
// // // //         appBar: AppBar(title: const Text('Google ML Kit Example')),
// // // //         body: const FaceDetectionExample(),
// // // //       ),
// // // //     );
// // // //   }
// // // // }

// // // // class FaceDetectionExample extends StatefulWidget {
// // // //   const FaceDetectionExample({super.key});

// // // //   @override
// // // //   FaceDetectionExampleState createState() => FaceDetectionExampleState();
// // // // }

// // // // class FaceDetectionExampleState extends State<FaceDetectionExample> {
// // // //   File? _imageFile;
// // // //   String _mlResult = 'No faces detected yet.';
// // // //   final _picker = ImagePicker();
// // // //   bool _isDetecting = false; // Track the detection process

// // // //   // Transparent placeholder image
// // // //   final Uint8List kTransparentImage = Uint8List.fromList([0x00, 0x00, 0x00, 0x00]);

// // // //   // Function to pick an image from the camera
// // // //   Future<bool> _pickImage(ImageSource source) async {
// // // //     setState(() {
// // // //       _imageFile = null;
// // // //       _mlResult = 'No faces detected yet.';
// // // //     });

// // // //     final XFile? pickedFile = await _picker.pickImage(source: source);

// // // //     if (pickedFile == null) {
// // // //       ScaffoldMessenger.of(context).showSnackBar(
// // // //         const SnackBar(content: Text('Please take or select a picture first.')),
// // // //       );
// // // //       return false;
// // // //     }

// // // //     setState(() => _imageFile = File(pickedFile.path));
// // // //     return true;
// // // //   }

// // // //   // Face detection function with error handling
// // // //   Future<void> _faceDetect() async {
// // // //     if (_isDetecting) return; // Prevent simultaneous detections
// // // //     setState(() {
// // // //       _isDetecting = true;
// // // //       _mlResult = 'Detecting faces...';
// // // //     });

// // // //     try {
// // // //       if (await _pickImage(ImageSource.camera) == false) {
// // // //         setState(() => _isDetecting = false);
// // // //         return;
// // // //       }

// // // //       String result = '';
// // // //       final InputImage inputImage = InputImage.fromFile(_imageFile!);

// // // //       final options = FaceDetectorOptions(
// // // //         enableLandmarks: true,
// // // //         enableClassification: true,
// // // //         enableTracking: true,
// // // //       );
// // // //       final FaceDetector faceDetector = FaceDetector(options: options);

// // // //       final List<Face> faces = await faceDetector.processImage(inputImage);
// // // //       result += 'Detected ${faces.length} face(s).\n';

// // // //       for (final Face face in faces) {
// // // //         final Rect boundingBox = face.boundingBox;
// // // //         final double? rotY = face.headEulerAngleY;
// // // //         final double? rotZ = face.headEulerAngleZ;
// // // //         result += '\n# Face:\n '
// // // //             'bbox=$boundingBox\n '
// // // //             'rotY=${rotY?.toStringAsFixed(2)}\n '
// // // //             'rotZ=${rotZ?.toStringAsFixed(2)}\n ';
// // // //         if (face.smilingProbability != null) {
// // // //           final double smileProb = face.smilingProbability!;
// // // //           result += 'smileProb=${smileProb.toStringAsFixed(3)}\n ';
// // // //         }
// // // //         if (face.trackingId != null) {
// // // //           final int id = face.trackingId!;
// // // //           result += 'id=$id\n ';
// // // //         }
// // // //       }

// // // //       faceDetector.close();

// // // //       setState(() {
// // // //         _mlResult = result.isNotEmpty ? result : 'No faces detected.';
// // // //       });
// // // //     } catch (e) {
// // // //       setState(() {
// // // //         _mlResult = 'Error during face detection: $e';
// // // //       });
// // // //     } finally {
// // // //       setState(() => _isDetecting = false); // Ensure the flag is reset
// // // //     }
// // // //   }

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return ListView(
// // // //       children: <Widget>[
// // // //         if (_imageFile == null)
// // // //           const Placeholder(
// // // //             fallbackHeight: 200.0,
// // // //           )
// // // //         else
// // // //           Image.file(_imageFile!),
// // // //         SingleChildScrollView(
// // // //           scrollDirection: Axis.horizontal,
// // // //           child: OverflowBar(
// // // //             children: <Widget>[
// // // //               ElevatedButton(
// // // //                 onPressed: _isDetecting ? null : _faceDetect,
// // // //                 child: Text(_isDetecting ? 'Detecting...' : 'Detect Faces'),
// // // //               ),
// // // //               ElevatedButton(
// // // //                 onPressed: _isDetecting ? null : () => _pickImage(ImageSource.gallery),
// // // //                 child: const Text('Pick from Gallery'),
// // // //               ),
// // // //             ],
// // // //           ),
// // // //         ),
// // // //         const Divider(),
// // // //         Text('Result:', style: Theme.of(context).textTheme.titleSmall),
// // // //         SingleChildScrollView(
// // // //           scrollDirection: Axis.horizontal,
// // // //           child: Text(
// // // //             _mlResult,
// // // //             style: const TextStyle(fontFamily: 'Courier'),
// // // //           ),
// // // //         ),
// // // //       ],
// // // //     );
// // // //   }
// // // // }





// // // // // import 'dart:io';
// // // // // import 'dart:typed_data';
// // // // // import 'package:flutter/material.dart';
// // // // // import 'package:image_picker/image_picker.dart';
// // // // // import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

// // // // // void main() {
// // // // //   runApp(const MyApp());
// // // // // }


// // // // // class MyApp extends StatelessWidget {
// // // // //   const MyApp({super.key});

// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     return MaterialApp(
// // // // //       debugShowCheckedModeBanner: false,
// // // // //       title: 'Google ML Kit Example',
// // // // //       theme: ThemeData(
// // // // //         primarySwatch: Colors.blue,
// // // // //       ),
// // // // //       home: Scaffold(
// // // // //         appBar: AppBar(title: const Text('Google ML Kit Example')),
// // // // //         body: const FaceDetectionExample(),
// // // // //       ),
// // // // //     );
// // // // //   }
// // // // // }



// // // // // class FaceDetectionExample extends StatefulWidget {
// // // // //   const FaceDetectionExample({super.key});

// // // // //   @override
// // // // //   FaceDetectionExampleState createState() => FaceDetectionExampleState();
// // // // // }

// // // // // class FaceDetectionExampleState extends State<FaceDetectionExample> {
// // // // //   File? _imageFile;
// // // // //   String _mlResult = '<no result>';
// // // // //   final _picker = ImagePicker();

// // // // //   // Transparent placeholder image
// // // // //   final Uint8List kTransparentImage = Uint8List.fromList([0x00, 0x00, 0x00, 0x00]);

// // // // //   // Function to pick an image from the camera
// // // // //   Future<bool> _pickImage() async {
// // // // //     setState(() => _imageFile = null);

// // // // //     final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);

// // // // //     if (pickedFile == null) {
// // // // //       ScaffoldMessenger.of(context).showSnackBar(
// // // // //         const SnackBar(content: Text('Please take a picture first.')),
// // // // //       );
// // // // //       return false;
// // // // //     }

// // // // //     setState(() => _imageFile = File(pickedFile.path));
// // // // //     return true;
// // // // //   }

// // // // //   // Face detection function
// // // // //   Future<void> _faceDetect() async {
// // // // //     setState(() => _mlResult = '<no result>');
// // // // //     if (await _pickImage() == false) {
// // // // //       return;
// // // // //     }
// // // // //     String result = '';
// // // // //     final InputImage inputImage = InputImage.fromFile(_imageFile!);

// // // // //     final options = FaceDetectorOptions(
// // // // //       enableLandmarks: true,
// // // // //       enableClassification: true,
// // // // //       enableTracking: true,
// // // // //     );
// // // // //     final FaceDetector faceDetector = FaceDetector(options: options);

// // // // //     final List<Face> faces = await faceDetector.processImage(inputImage);
// // // // //     result += 'Detected ${faces.length} faces.\n';
// // // // //     for (final Face face in faces) {
// // // // //       final Rect boundingBox = face.boundingBox;
// // // // //       final double? rotY = face.headEulerAngleY;
// // // // //       final double? rotZ = face.headEulerAngleZ;
// // // // //       result += '\n# Face:\n '
// // // // //           'bbox=$boundingBox\n '
// // // // //           'rotY=${rotY?.toStringAsFixed(2)}\n '
// // // // //           'rotZ=${rotZ?.toStringAsFixed(2)}\n ';
// // // // //       if (face.smilingProbability != null) {
// // // // //         final double smileProb = face.smilingProbability!;
// // // // //         result += 'smileProb=${smileProb.toStringAsFixed(3)}\n ';
// // // // //       }
// // // // //       if (face.trackingId != null) {
// // // // //         final int id = face.trackingId!;
// // // // //         result += 'id=$id\n ';
// // // // //       }
// // // // //     }
// // // // //     faceDetector.close();
// // // // //     if (result.isNotEmpty) {
// // // // //       setState(() => _mlResult = result);
// // // // //     }
// // // // //   }

// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     return ListView(
// // // // //       children: <Widget>[
// // // // //         if (_imageFile == null)
// // // // //           const Placeholder(
// // // // //             fallbackHeight: 200.0,
// // // // //           )
// // // // //         else
// // // // //           Image.file(_imageFile!),
// // // // //         SingleChildScrollView(
// // // // //           scrollDirection: Axis.horizontal,
// // // // //           child: OverflowBar(
// // // // //             children: <Widget>[
// // // // //               ElevatedButton(
// // // // //                 onPressed: _faceDetect,
// // // // //                 child: const Text('Detect Faces'),
// // // // //               ),
// // // // //             ],
// // // // //           ),
// // // // //         ),
// // // // //         const Divider(),
// // // // //         Text('Result:', style: Theme.of(context).textTheme.titleSmall),
// // // // //         SingleChildScrollView(
// // // // //           scrollDirection: Axis.horizontal,
// // // // //           child: Text(
// // // // //             _mlResult,
// // // // //             style: const TextStyle(fontFamily: 'Courier'),
// // // // //           ),
// // // // //         ),
// // // // //       ],
// // // // //     );
// // // // //   }
// // // // // }

























// // // // // import 'dart:io';
// // // // // import 'dart:typed_data';
// // // // // import 'package:flutter/material.dart';
// // // // // import 'package:google_fonts/google_fonts.dart';
// // // // // import 'package:image_picker/image_picker.dart';
// // // // // import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
// // // // // import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
// // // // // import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
// // // // // import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

// // // // // void main() {
// // // // //   runApp(const MyApp());
// // // // // }

// // // // // class MyApp extends StatelessWidget {
// // // // //   const MyApp({super.key});

// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     return MaterialApp(
// // // // //       debugShowCheckedModeBanner: false,
// // // // //       title: 'Google ML Kit Example',
// // // // //       theme: ThemeData(
// // // // //         primarySwatch: Colors.blue,
// // // // //       ),
// // // // //       home: Scaffold(
// // // // //         appBar: AppBar(title: const Text('Google ML Kit Example')),
// // // // //         body: const GoogleMLKitExample(),
// // // // //       ),
// // // // //     );
// // // // //   }
// // // // // }

// // // // // class GoogleMLKitExample extends StatefulWidget {
// // // // //   const GoogleMLKitExample({super.key});

// // // // //   @override
// // // // //   GoogleMLKitExampleState createState() => GoogleMLKitExampleState();
// // // // // }

// // // // // class GoogleMLKitExampleState extends State<GoogleMLKitExample> {
// // // // //   File? _imageFile;
// // // // //   String _mlResult = '<no result>';
// // // // //   final _picker = ImagePicker();

// // // // //   // Transparent placeholder image
// // // // //   final Uint8List kTransparentImage = Uint8List.fromList([0x00, 0x00, 0x00, 0x00]);

// // // // //   // Function to pick an image from the camera
// // // // //   Future<bool> _pickImage() async {
// // // // //     setState(() => _imageFile = null);

// // // // //     final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);

// // // // //     if (pickedFile == null) {
// // // // //       ScaffoldMessenger.of(context).showSnackBar(
// // // // //         const SnackBar(content: Text('Please take a picture first.')),
// // // // //       );
// // // // //       return false;
// // // // //     }

// // // // //     setState(() => _imageFile = File(pickedFile.path));
// // // // //     return true;
// // // // //   }

// // // // //   // Image labeling function
// // // // //   Future<void> _imageLabelling() async {
// // // // //     setState(() => _mlResult = '<no result>');
// // // // //     if (await _pickImage() == false) {
// // // // //       return;
// // // // //     }
// // // // //     String result = '';
// // // // //     final InputImage inputImage = InputImage.fromFile(_imageFile!);

// // // // //     final options = ImageLabelerOptions(confidenceThreshold: 0.7);
// // // // //     final ImageLabeler imageLabeler = ImageLabeler(options: options);

// // // // //     final List<ImageLabel> labels = await imageLabeler.processImage(inputImage);
// // // // //     result += 'Detected ${labels.length} labels.\n';
// // // // //     for (final ImageLabel label in labels) {
// // // // //       final String text = label.label;
// // // // //       final double confidence = label.confidence;
// // // // //       result += '\n#Label: $text, confidence=${confidence.toStringAsFixed(3)}';
// // // // //     }
// // // // //     imageLabeler.close();
// // // // //     if (result.isNotEmpty) {
// // // // //       setState(() => _mlResult = result);
// // // // //     }
// // // // //   }

// // // // //   // Face detection function
// // // // //   Future<void> _faceDetect() async {
// // // // //     setState(() => _mlResult = '<no result>');
// // // // //     if (await _pickImage() == false) {
// // // // //       return;
// // // // //     }
// // // // //     String result = '';
// // // // //     final InputImage inputImage = InputImage.fromFile(_imageFile!);

// // // // //     final options = FaceDetectorOptions(
// // // // //       enableLandmarks: true,
// // // // //       enableClassification: true,
// // // // //       enableTracking: true,
// // // // //     );
// // // // //     final FaceDetector faceDetector = FaceDetector(options: options);

// // // // //     final List<Face> faces = await faceDetector.processImage(inputImage);
// // // // //     result += 'Detected ${faces.length} faces.\n';
// // // // //     for (final Face face in faces) {
// // // // //       final Rect boundingBox = face.boundingBox;
// // // // //       final double? rotY = face.headEulerAngleY;
// // // // //       final double? rotZ = face.headEulerAngleZ;
// // // // //       result += '\n# Face:\n '
// // // // //           'bbox=$boundingBox\n '
// // // // //           'rotY=${rotY?.toStringAsFixed(2)}\n '
// // // // //           'rotZ=${rotZ?.toStringAsFixed(2)}\n ';
// // // // //       if (face.smilingProbability != null) {
// // // // //         final double smileProb = face.smilingProbability!;
// // // // //         result += 'smileProb=${smileProb.toStringAsFixed(3)}\n ';
// // // // //       }
// // // // //       if (face.trackingId != null) {
// // // // //         final int id = face.trackingId!;
// // // // //         result += 'id=$id\n ';
// // // // //       }
// // // // //     }
// // // // //     faceDetector.close();
// // // // //     if (result.isNotEmpty) {
// // // // //       setState(() => _mlResult = result);
// // // // //     }
// // // // //   }

// // // // //   // Text recognition (OCR) function
// // // // //   Future<void> _textOcr() async {
// // // // //     setState(() => _mlResult = '<no result>');
// // // // //     if (await _pickImage() == false) {
// // // // //       return;
// // // // //     }
// // // // //     String result = '';
// // // // //     final InputImage inputImage = InputImage.fromFile(_imageFile!);

// // // // //     final TextRecognizer textRecognizer = TextRecognizer();
// // // // //     final RecognizedText recognizedText =
// // // // //         await textRecognizer.processImage(inputImage);

// // // // //     for (final TextBlock block in recognizedText.blocks) {
// // // // //       result += 'Block: ${block.text}\n';
// // // // //     }

// // // // //     textRecognizer.close();
// // // // //     if (result.isNotEmpty) {
// // // // //       setState(() => _mlResult = result);
// // // // //     }
// // // // //   }

// // // // //   // Barcode scanning function
// // // // //   Future<void> _barcodeScan() async {
// // // // //     setState(() => _mlResult = '<no result>');
// // // // //     if (await _pickImage() == false) {
// // // // //       return;
// // // // //     }
// // // // //     String result = '';
// // // // //     final InputImage inputImage = InputImage.fromFile(_imageFile!);

// // // // //     final BarcodeScanner barcodeScanner = BarcodeScanner();
// // // // //     final List<Barcode> barcodes = await barcodeScanner.processImage(inputImage);

// // // // //     for (final Barcode barcode in barcodes) {
// // // // //       result += 'Barcode: ${barcode.rawValue}\n';
// // // // //     }

// // // // //     barcodeScanner.close();
// // // // //     if (result.isNotEmpty) {
// // // // //       setState(() => _mlResult = result);
// // // // //     }
// // // // //   }

// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     return ListView(
// // // // //       children: <Widget>[
// // // // //         if (_imageFile == null)
// // // // //           const Placeholder(
// // // // //             fallbackHeight: 200.0,
// // // // //           )
// // // // //         else
// // // // //           Image.file(_imageFile!),
// // // // //         SingleChildScrollView(
// // // // //           scrollDirection: Axis.horizontal,
// // // // //           child: OverflowBar(
// // // // //             children: <Widget>[
// // // // //               ElevatedButton(
// // // // //                 onPressed: _imageLabelling,
// // // // //                 child: const Text('Image Labelling'),
// // // // //               ),
// // // // //               ElevatedButton(
// // // // //                 onPressed: _textOcr,
// // // // //                 child: const Text('Text OCR'),
// // // // //               ),
// // // // //               ElevatedButton(
// // // // //                 onPressed: _barcodeScan,
// // // // //                 child: const Text('Barcode Scan'),
// // // // //               ),
// // // // //               ElevatedButton(
// // // // //                 onPressed: _faceDetect,
// // // // //                 child: const Text('Face Detection'),
// // // // //               ),
// // // // //             ],
// // // // //           ),
// // // // //         ),
// // // // //         const Divider(),
// // // // //         Text('Result:', style: Theme.of(context).textTheme.titleSmall),
// // // // //         SingleChildScrollView(
// // // // //           scrollDirection: Axis.horizontal,
// // // // //           child: Text(
// // // // //             _mlResult,
// // // // //             style: GoogleFonts.notoSansMono(),
// // // // //           ),
// // // // //         ),
// // // // //       ],
// // // // //     );
// // // // //   }
// // // // // }

