import 'package:cloud_firestore/cloud_firestore.dart';

class Movie {
  String? id;
  String titulo;
  String director;
  int puntuacion;
  Movie({
    this.id,
    required this.titulo,
    required this.director,
    required this.puntuacion,
  });

  Map<String, dynamic> toMap() => {
    'titulo': titulo,
    'director': director,
    'puntuacion': puntuacion,
  };

  factory Movie.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Movie(
      id: doc.id,
      titulo: data['titulo'] ?? '',
      director: data['director'] ?? '',
      puntuacion: data['puntuacion'] ?? 5,
    );
  }
}
