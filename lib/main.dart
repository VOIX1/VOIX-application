import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/glove_home_screen.dart';

void main() async {
  // Ensure Flutter engine bindings are initialized for async call
  WidgetsFlutterBinding.ensureInitialized();

  // Check persistent storage for active login session
  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VOIX',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
        useMaterial3: true,
      ),
      // Automatically route to Home if logged in, otherwise show Login
      home: isLoggedIn ? const GloveHomeScreen() : const LoginScreen(),
    );
  }
}