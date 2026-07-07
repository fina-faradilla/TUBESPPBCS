import 'package:flutter/material.dart';

import 'screens/public/landing_page.dart';
import 'screens/public/login_page.dart';
import 'screens/public/register_page.dart';

void main() {
  runApp(const RoadFixApp());
}

class RoadFixApp extends StatelessWidget {
  const RoadFixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RoadFix',

      theme: ThemeData(
        colorSchemeSeed: Colors.orange,
        useMaterial3: true,
      ),

      initialRoute: '/',

      routes: {
        '/': (context) => const LandingPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
      },
    );
  }
}