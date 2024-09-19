import 'package:flutter/material.dart';
import '../home/presentation/home_page.dart';
import '../login/presentation/login_page.dart';
import '../splash/presentation/splash_screen.dart';



class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case home:
        return MaterialPageRoute(builder: (_) => const MyHomePage(title: 'ZONIX Dashboard'));
      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }
}
