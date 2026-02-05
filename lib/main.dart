import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'screens/auth_screen.dart';
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
    return MaterialApp(
      title: 'RewindTV',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthScreen(),
        '/home': (context) => const HomeScreen(),
      },
      theme: ThemeData(
        // Activamos Material 3 para diseños modernos (borde redondeados suaves, efectos de pulsación, etc)
        useMaterial3: true,
        brightness: Brightness.dark,

        // Esto es lo que ahorra código: Generamos toda la paleta desde un solo color base
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF00FF), // Magenta base
          brightness: Brightness.dark,
          surface: const Color(
            0xFF1E1E2C,
          ), // Color para las tarjetas/diálogos (gris azulado moderno)
          primary: const Color(0xFFFF00FF),
          secondary: const Color(0xFF00FFFF), // Cian para acentos
        ),

        // Fondo principal oscuro pero limpio
        scaffoldBackgroundColor: const Color(0xFF0D0213),

        appBarTheme: const AppBarTheme(
          backgroundColor:
              Colors.transparent, // Barra transparente estilo moderno
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),
    );
  }
}
