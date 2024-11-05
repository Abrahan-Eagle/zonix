import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Importa flutter_svg
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'onboarding_page1.dart';
import 'onboarding_page2.dart';
import 'onboarding_page3.dart';
import 'onboarding_page4.dart';
import 'onboarding_page5.dart';
// import './profile_screen.dart';
// import './address_screen.dart';
// import './document_screen.dart';
// import './gas_cylinder_screen.dart';

class OnboardingScreen extends StatefulWidget {
  
  const OnboardingScreen({super.key}); // Hacer que userId sea opcional

  @override
  OnboardingScreenState createState() => OnboardingScreenState();
}

class OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  List<Widget> get onboardingPages {
    return [
      const WelcomePage(),
      const OnboardingPage1(),
     const OnboardingPage2(), // Usar un valor predeterminado (ej. 0)
      // ProfileScreen(),
      const OnboardingPage3(),
      // AddressScreen(),
      const OnboardingPage4(),
      // DocumentScreen(),
      const OnboardingPage5(),
      // const GasCylinderScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Evita que se salga del Onboarding al presionar el botón de retroceso
        return false; // Retorna false para evitar la salida
      },
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
                onPressed: () {
                  if (_currentPage == onboardingPages.length - 1) {
                    // Lógica para finalizar el onboarding
                    Navigator.of(context).pop(); // O redirige a otra pantalla
                  } else {
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
                  }
                },
                child: Text(_currentPage == onboardingPages.length - 1 ? 'Finalizar' : 'Siguiente'),
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
          SvgPicture.asset('assets/onboarding/welcome_image.svg', height: 200), // Cargar SVG
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
