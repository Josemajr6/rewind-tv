import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtenemos el usuario actual
    final user = AuthService().currentUser;
    // Color temático para el perfil (Amarillo neón para seguir la estética)
    const Color colorPerfil = Color(0xFFFFD700);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0213), // Mismo fondo que Home
      body: Center(
        child: user == null
            ? _buildGuestView(context, colorPerfil)
            : _buildUserView(context, user, colorPerfil),
      ),
    );
  }

  // Vista para INVITADO
  Widget _buildGuestView(BuildContext context, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const FaIcon(
          FontAwesomeIcons.userAstronaut,
          size: 80,
          color: Colors.white24,
        ),
        const SizedBox(height: 20),
        const Text(
          "MODO INVITADO",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            "Inicia sesión con Google para guardar tus series, pelis y juegos en la nube.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54),
          ),
        ),
        const SizedBox(height: 40),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          ),
          icon: const FaIcon(FontAwesomeIcons.google, size: 18),
          label: const Text("CONECTAR CON GOOGLE"),
          onPressed: () => AuthService().signInWithGoogle(context),
        ),
      ],
    );
  }

  // Vista para USUARIO LOGUEADO
  Widget _buildUserView(BuildContext context, dynamic user, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Foto de perfil con borde neón
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 3),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 60,
            backgroundImage: NetworkImage(user.photoURL ?? ''),
            backgroundColor: Colors.grey[800],
            child: user.photoURL == null
                ? const Icon(Icons.person, size: 60, color: Colors.white)
                : null,
          ),
        ),
        const SizedBox(height: 30),
        Text(
          user.displayName ?? "USUARIO",
          style: TextStyle(
            color: color,
            fontSize: 26,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          user.email ?? "",
          style: const TextStyle(color: Colors.white54, fontSize: 16),
        ),
        const SizedBox(height: 50),

        // Botón de cerrar sesión
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.redAccent),
            foregroundColor: Colors.redAccent,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          ),
          icon: const Icon(Icons.logout),
          label: const Text("CERRAR SESIÓN"),
          onPressed: () => AuthService().signOut(context),
        ),
      ],
    );
  }
}
