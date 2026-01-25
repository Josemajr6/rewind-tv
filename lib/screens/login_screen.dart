import 'package:flutter/material.dart';
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // LOGO EN EL MEDIO (Grande y con brillo)
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: magenta,
                      blurRadius: 100,
                      spreadRadius: -20,
                    ),
                  ],
                ),
                child: Image.asset('assets/logo.png', height: 250),
              ),
              const SizedBox(height: 60),

              // BOTONES
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: magenta,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () => AuthService().signInWithGoogle(context),
                child: const Text(
                  "ENTRAR CON GOOGLE",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: cian, width: 2),
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/home'),
                child: const Text(
                  "MODO INVITADO",
                  style: TextStyle(color: cian, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
