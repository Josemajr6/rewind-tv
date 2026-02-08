import 'package:firebase_auth/firebase_auth.dart';

class Movie {
  final String id;
  final String titulo;
  final String director;
  final int puntuacion;
  final String userId;
  final String plataforma;
  final String resena;
  final String genero;

  Movie({
    this.id = '',
    required this.titulo,
    required this.director,
    required this.puntuacion,
    String? userId, // ahora es opcional
    required this.plataforma,
    required this.resena,
    required this.genero,
  }) : userId = userId ?? FirebaseAuth.instance.currentUser?.uid ?? 'invitado';

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'director': director,
      'puntuacion': puntuacion,
      'userId': userId,
      'plataforma': plataforma,
      'resena': resena,
      'genero': genero,
    };
  }

  factory Movie.fromMap(Map<String, dynamic> map, String documentId) {
    return Movie(
      id: documentId,
      titulo: map['titulo'] ?? '',
      director: map['director'] ?? '',
      puntuacion: map['puntuacion']?.toInt() ?? 0,
      userId: map['userId'] ?? '',
      plataforma: map['plataforma'] ?? 'Cine',
      resena: map['resena'] ?? '',
      genero: map['genero'] ?? 'Otro',
    );
  }
}
