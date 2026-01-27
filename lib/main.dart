import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const RewindTVApp());
}

class RewindTVApp extends StatelessWidget {
  const RewindTVApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color magenta = Color(0xFFFF00FF);
    const Color cian = Color(0xFF00FFFF);

    return MaterialApp(
      title: 'RewindTV',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D0213),
        fontFamily: 'monospace',
        colorScheme: const ColorScheme.dark(
          primary: magenta,
          secondary: cian,
          surface: Color(0xFF1A0225),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          centerTitle: true,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: magenta,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ),
    );
  }
}
