import 'package:flutter/material.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/home/screens/home_shell.dart';

void main() {
  runApp(const MedixApp());
}

class MedixApp extends StatelessWidget {
  const MedixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medix Mobile',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/home': (_) => const MainHomeScreen(),
      },
    );
  }
}
