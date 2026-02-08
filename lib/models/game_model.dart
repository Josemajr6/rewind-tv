import 'package:firebase_auth/firebase_auth.dart';

class Game {
  final String id;
  final String titulo;
  final String plataforma;
  final int puntuacion;
  final String userId;
  final String resena;

  Game({
    this.id = '',
    required this.titulo,
    required this.plataforma,
    required this.puntuacion,
    String? userId, // ahora es opcional
    required this.resena,
  }) : userId = userId ?? FirebaseAuth.instance.currentUser?.uid ?? 'invitado';

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'plataforma': plataforma,
      'puntuacion': puntuacion,
      'userId': userId,
      'resena': resena,
    };
  }

  factory Game.fromMap(Map<String, dynamic> map, String documentId) {
    return Game(
      id: documentId,
      titulo: map['titulo'] ?? '',
      plataforma: map['plataforma'] ?? 'PC',
      puntuacion: map['puntuacion']?.toInt() ?? 0,
      userId: map['userId'] ?? '',
      resena: map['resena'] ?? '',
    );
  }
}
