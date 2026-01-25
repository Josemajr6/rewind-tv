import 'package:cloud_firestore/cloud_firestore.dart';

class Serie {
  String? id;
  String titulo;
  String resena;
  String genero;
  int temporadas;
  int puntuacion;
  String uidPropietario;

  Serie({
    this.id,
    required this.titulo,
    required this.resena,
    required this.genero,
    required this.temporadas,
    required this.puntuacion,
    required this.uidPropietario,
  });

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'resena': resena,
      'genero': genero,
      'temporadas': temporadas,
      'puntuacion': puntuacion,
      'uidPropietario': uidPropietario,
    };
  }

  factory Serie.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Serie(
      id: doc.id,
      titulo: data['titulo'] ?? '',
      resena: data['resena'] ?? '',
      genero: data['genero'] ?? 'Acción', // <--- COINCIDE CON LA LISTA
      temporadas: (data['temporadas'] ?? 1).toInt(),
      puntuacion: (data['puntuacion'] ?? 5).toInt(),
      uidPropietario: data['uidPropietario'] ?? '',
    );
  }
}
