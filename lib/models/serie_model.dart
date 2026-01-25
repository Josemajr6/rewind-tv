import 'package:cloud_firestore/cloud_firestore.dart';

class Serie {
  String? id;
  String titulo;
  String genero;
  int temporadas;
  int puntuacion;
  String estado;
  String uidPropietario;

  Serie({
    this.id,
    required this.titulo,
    required this.genero,
    required this.temporadas,
    required this.puntuacion,
    required this.estado,
    required this.uidPropietario,
  });

  // Convierte el objeto a un Mapa para guardarlo en Firestore
  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'genero': genero,
      'temporadas': temporadas,
      'puntuacion': puntuacion,
      'estado': estado,
      'uidPropietario': uidPropietario,
    };
  }

  // Crea un objeto Serie a partir de un documento de Firestore
  factory Serie.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Serie(
      id: doc.id,
      titulo: data['titulo'] ?? '',
      genero: data['genero'] ?? '',
      temporadas: data['temporadas'] ?? 0,
      puntuacion: data['puntuacion'] ?? 0,
      estado: data['estado'] ?? 'pendiente',
      uidPropietario: data['uidPropietario'] ?? '',
    );
  }
}
