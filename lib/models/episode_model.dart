import 'package:cloud_firestore/cloud_firestore.dart';

class Episode {
  String? id;
  String titulo;
  int numero;
  int puntuacion;
  String resena;
  String serieId;

  Episode({
    this.id,
    required this.titulo,
    required this.numero,
    required this.puntuacion,
    required this.resena,
    required this.serieId,
  });

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'numero': numero,
      'puntuacion': puntuacion,
      'resena': resena,
      'serieId': serieId,
    };
  }

  factory Episode.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Episode(
      id: doc.id,
      titulo: data['titulo'] ?? '',
      numero: (data['numero'] ?? 0).toInt(),
      puntuacion: (data['puntuacion'] ?? 5).toInt(),
      resena: data['resena'] ?? '',
      serieId: data['serieId'] ?? '',
    );
  }
}
