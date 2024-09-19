import 'package:flutter/material.dart';
import 'features/splash/presentation/splash_screen.dart';
import './features/config/theme.dart';

void main() {
  runApp(const MyApp());
  
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZONIX',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,  // Referencia a los temas que vamos a modularizar
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}
