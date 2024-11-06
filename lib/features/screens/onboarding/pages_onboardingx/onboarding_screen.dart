import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; 
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'onboarding_page1.dart';
import 'onboarding_page2.dart';
import 'onboarding_page2x.dart';
import 'onboarding_page3.dart';
import 'onboarding_page4.dart';
import 'onboarding_page5.dart';
import 'package:zonix/features/utils/user_provider.dart'; // Asegúrate de que este import sea correcto
import 'package:provider/provider.dart';
import 'onboarding_service.dart';
import 'package:zonix/main.dart';

 final OnboardingService _onboardingService = OnboardingService();
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  OnboardingScreenState createState() => OnboardingScreenState();
}

class OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  List<Widget> get onboardingPages {
    return const [
      WelcomePage(),
      OnboardingPage1(),
      OnboardingPage2(),
      OnboardingPage2x(),
      OnboardingPage3(),
      OnboardingPage4(),
      OnboardingPage5(),
    ];
  }

  Future<void> _completeOnboarding(int userId) async {
    // Lógica para completar el onboarding, incluyendo el manejo de errores
    try {
      await _onboardingService.completeOnboarding(userId);
      debugPrint("Onboarding completado con éxito.");

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainRouter()),
        );
      // Navigator.of(context).pop(); // Cambia a la pantalla principal u otra vista
    } catch (e) {
      debugPrint("Error al completar el onboarding: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al completar el onboarding')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: PageView(
          controller: _controller,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          children: onboardingPages,
        ),
        bottomSheet: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          height: 80.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SmoothPageIndicator(
                controller: _controller,
                count: onboardingPages.length,
                effect: const WormEffect(),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_currentPage == onboardingPages.length - 1) {
                    final userProvider = Provider.of<UserProvider>(context, listen: false);
                    final userId = userProvider.userId; // Asegúrate de que userId esté disponible
                    await _completeOnboarding(userId);
                  } else {
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
                  }
                },
                child: Text(
                  _currentPage == onboardingPages.length - 1 ? 'Finalizar' : 'Siguiente',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset('assets/onboarding/welcome_image.svg', height: 200),
          const SizedBox(height: 20),
          const Text(
            '¡Bienvenido a Zonix!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'La forma más rápida y segura de gestionar tus bombonas de gas. '
              'Aquí puedes gestionar tus citas de manera eficiente.',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart'; // Importa flutter_svg
// import 'package:smooth_page_indicator/smooth_page_indicator.dart';
// import 'onboarding_page1.dart';
// import 'onboarding_page2.dart';
// import 'onboarding_page3.dart';
// import 'onboarding_page4.dart';
// import 'onboarding_page5.dart';
// // import './profile_screen.dart';
// // import './address_screen.dart';
// // import './document_screen.dart';
// // import './gas_cylinder_screen.dart';

// class OnboardingScreen extends StatefulWidget {
  
//   const OnboardingScreen({super.key}); // Hacer que userId sea opcional

//   @override
//   OnboardingScreenState createState() => OnboardingScreenState();
// }

// class OnboardingScreenState extends State<OnboardingScreen> {
//   final PageController _controller = PageController();
//   int _currentPage = 0;

//   List<Widget> get onboardingPages {
//     return [
//       const WelcomePage(),
//       const OnboardingPage1(),
//      const OnboardingPage2(), // Usar un valor predeterminado (ej. 0)
//       // ProfileScreen(),
//       const OnboardingPage3(),
//       // AddressScreen(),
//       const OnboardingPage4(),
//       // DocumentScreen(),
//       const OnboardingPage5(),
//       // const GasCylinderScreen(),
//     ];
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         // Evita que se salga del Onboarding al presionar el botón de retroceso
//         return false; // Retorna false para evitar la salida
//       },
//       child: Scaffold(
//         body: PageView(
//           controller: _controller,
//           onPageChanged: (index) {
//             setState(() {
//               _currentPage = index;
//             });
//           },
//           children: onboardingPages,
//         ),
//         bottomSheet: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0),
//           height: 80.0,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               SmoothPageIndicator(
//                 controller: _controller,
//                 count: onboardingPages.length,
//                 effect: const WormEffect(),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   if (_currentPage == onboardingPages.length - 1) {
//                     // Lógica para finalizar el onboarding
//                     Navigator.of(context).pop(); // O redirige a otra pantalla
//                   } else {
//                     _controller.nextPage(
//                       duration: const Duration(milliseconds: 300),
//                       curve: Curves.easeIn,
//                     );
//                   }
//                 },
//                 child: Text(_currentPage == onboardingPages.length - 1 ? 'Finalizar' : 'Siguiente'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class WelcomePage extends StatelessWidget {
//   const WelcomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           SvgPicture.asset('assets/onboarding/welcome_image.svg', height: 200), // Cargar SVG
//           const SizedBox(height: 20),
//           const Text(
//             '¡Bienvenido a Zonix!',
//             style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//           ),
//           const Padding(
//             padding: EdgeInsets.all(16.0),
//             child: Text(
//               'La forma más rápida y segura de gestionar tus bombonas de gas. '
//               'Aquí puedes gestionar tus citas de manera eficiente.',
//               textAlign: TextAlign.center,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
