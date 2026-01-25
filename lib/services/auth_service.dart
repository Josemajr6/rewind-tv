import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../screens/home_screen.dart';
import '../screens/login_screen.dart';

class AuthService {
  // Instancias de Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Método para iniciar sesión con Google
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      // Disparar el flujo de autenticación de Google (abre la ventana modal)
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) return; // Si cancela el login

      // Obtener los detalles de autenticación de la petición
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Crear una credencial para Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Usar la credencial para entrar en Firebase
      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      User? user = userCredential.user;

      if (user != null) {
        // Guardar en 'Users'
        // Verificamos si el usuario ya existe para no sobrescribir datos si fuera necesario
        // (Aunque aquí usaremos set con merge para actualizar datos si cambian)
        await _db.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'nombre': user.displayName ?? 'Usuario Retro',
          'email': user.email,
          'fotoUrl': user.photoURL,
          'ultimo_login': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // 5. Navegar a la Home
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      }
    } catch (e) {
      print("Error en Login Google: $e");
      // Mostrar un error visual simple (SnackBar)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error de conexión: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Método para cerrar sesión
  Future<void> signOut(BuildContext context) async {
    await _googleSignIn.signOut();
    await _auth.signOut();

    // Volver al Login
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  // Obtener usuario actual
  User? get currentUser => _auth.currentUser;
}
