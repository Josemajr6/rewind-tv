import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const RewindTVApp());
}

class RewindTVApp extends StatelessWidget {
  const RewindTVApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color retroPurple = Color(0xFF9D089D);
    const Color neonCyan = Color(0xFF00FFFF);

    return MaterialApp(
      title: 'RewindTV',
      debugShowCheckedModeBanner: false,

      // CONFIGURACIÓN DEL TEMA
      theme: ThemeData(
        brightness: Brightness.dark,
        // Fondo muy oscuro pero con un tinte morado casi negro
        scaffoldBackgroundColor: const Color(0xFF120512),

        colorScheme: const ColorScheme.dark(
          primary: retroPurple, // Tu morado principal
          secondary: neonCyan, // Azul cian para contrastes
          surface: Color(0xFF1E0B1E),
        ),

        fontFamily: 'Courier',
        // Estilo global de inputs (Cajas de texto)
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2D152D),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: neonCyan,
              width: 2,
            ), // Brillo cian al escribir
          ),
        ),
      ),

      home: const LoginScreen(),
    );
  }
}
