import 'package:flutter/material.dart';
import 'startup_screen.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'navigation_wrapper.dart';
import 'profile_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } else {
      await Firebase.initializeApp();
    }
    print('Firebase initialized successfully');

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User is signed out');
      } else {
        print('User is signed in with email: ${user.email}');
      }
    });
  } catch (e) {
    print('Firebase initialization error: $e');
  }
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
