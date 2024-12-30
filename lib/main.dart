import 'package:flutter/material.dart';
import 'startup_screen.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'navigation_wrapper.dart';
import 'profile_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AgriSage',
      theme: ThemeData(
        primaryColor: const Color(0xFF2ECC71),
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF2ECC71),
          secondary: Color(0xFF2C3E50),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const StartupScreen(),
        '/home': (context) => const NavigationWrapper(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}
