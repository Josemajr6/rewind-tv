import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Importamos la librería
import '../services/auth_service.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color magenta = Color(0xFFFF00FF);
    const Color cian = Color(0xFF00FFFF);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0213),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. LOGO CON BRILLO NEÓN (Corregido)
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: magenta.withOpacity(0.3), // Brillo sutil
                      blurRadius: 50, // Difuminado amplio
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/logo-completo.png',
                  height: 200,
                  // Si el logo no existe, ponemos un icono de repuesto para que no pete
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.videocam, size: 100, color: magenta),
                ),
              ),
              const SizedBox(height: 60),

              // 2. BOTÓN GOOGLE (Con FontAwesome)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
                onPressed: () => AuthService().signInWithGoogle(context),
                // USAMOS FONT AWESOME: Cero errores de carga
                icon: const FaIcon(
                  FontAwesomeIcons.google,
                  color: Color(0xFFDB4437),
                  size: 20,
                ),
                label: const Text(
                  "ENTRAR CON GOOGLE",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 3. BOTÓN INVITADO (Con FontAwesome)
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: cian, width: 2),
                  foregroundColor: cian,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/home'),
                icon: const FaIcon(
                  FontAwesomeIcons.userSecret,
                  color: cian,
                  size: 20,
                ),
                label: const Text(
                  "MODO INVITADO",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
