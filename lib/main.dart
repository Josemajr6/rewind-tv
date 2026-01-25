import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

// Importación de pantallas (Según tu estructura de directorios)
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_serie_screen.dart';
import 'screens/serie_detail_screen.dart';

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

      // Definición de las Rutas para el 10
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/add-serie': (context) => const AddSerieScreen(),
        '/serie-detail': (context) => const SerieDetailScreen(),
      },

      // Configuración del Tema 80s/Neon
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D0213), // Fondo ultra oscuro
        fontFamily: 'monospace', // Fuente estilo terminal

        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF00FF), // Magenta Neón
          secondary: Color(0xFF00FFFF), // Cian Neón
          surface: Color(0xFF1A0225), // Fondo de tarjetas/diálogos
        ),

        // Personalización de estilos de botones para toda la app
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF00FF),
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),

        // Estilo de los textos
        textTheme: const TextTheme(
          bodyLarge: TextStyle(letterSpacing: 1.2, color: Colors.white),
          titleLarge: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
            color: Color(0xFF00FFFF),
          ),
        ),
      ),
    );
  }
}
