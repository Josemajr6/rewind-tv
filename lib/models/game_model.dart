import 'package:cloud_firestore/cloud_firestore.dart';

class Game {
  String? id;
  String titulo;
  String plataforma;
  String estado;
  int puntuacion;

  Game({
    this.id,
    required this.titulo,
    required this.plataforma,
    required this.estado,
    required this.puntuacion,
  });

  Map<String, dynamic> toMap() => {
    'titulo': titulo,
    'plataforma': plataforma,
    'estado': estado,
    'puntuacion': puntuacion,
  };

  factory Game.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Game(
      id: doc.id,
      titulo: data['titulo'] ?? '',
      plataforma: data['plataforma'] ?? 'PC',
      estado: data['estado'] ?? 'Jugando',
      puntuacion: data['puntuacion'] ?? 5,
    );
  }
}
