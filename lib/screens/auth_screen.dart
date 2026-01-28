import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/auth_service.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

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
              // Logo con efecto neón
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: magenta.withOpacity(0.3), blurRadius: 50),
                  ],
                ),
                child: Image.asset(
                  'assets/logo-completo.png',
                  height: 200,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.videocam, size: 100, color: magenta),
                ),
              ),
              const SizedBox(height: 60),

              // Botón de Google Sign In
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  elevation: 5,
                ),
                onPressed: () => AuthService().signInWithGoogle(context),
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

              // Botón de modo invitado
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: cian, width: 2),
                  foregroundColor: cian,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
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
