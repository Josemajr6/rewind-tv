class Serie {
  final String id;
  final String titulo;
  final String resena;
  final String genero;
  final int puntuacion;
  final String userId;
  final String plataforma;

  Serie({
    this.id = '',
    required this.titulo,
    required this.resena,
    required this.genero,
    required this.puntuacion,
    this.userId = '',
    required this.plataforma,
  });

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'resena': resena,
      'genero': genero,
      'puntuacion': puntuacion,
      'userId': userId,
      'plataforma': plataforma,
    };
  }

  factory Serie.fromMap(Map<String, dynamic> map, String documentId) {
    return Serie(
      id: documentId,
      titulo: map['titulo'] ?? '',
      resena: map['resena'] ?? '',
      genero: map['genero'] ?? 'Otro',
      puntuacion: map['puntuacion']?.toInt() ?? 0,
      userId: map['userId'] ?? '',
      plataforma: map['plataforma'] ?? 'Otras',
    );
  }
}
