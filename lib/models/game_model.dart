class Game {
  final String id;
  final String titulo;
  final String plataforma;
  final String estado;
  final int puntuacion;
  final String userId;
  final String resena;

  Game({
    this.id = '',
    required this.titulo,
    required this.plataforma,
    required this.estado,
    required this.puntuacion,
    this.userId = '',
    required this.resena,
  });

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'plataforma': plataforma,
      'estado': estado,
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
      estado: map['estado'] ?? 'Jugando',
      puntuacion: map['puntuacion']?.toInt() ?? 0,
      userId: map['userId'] ?? '',
      resena: map['resena'] ?? '',
    );
  }
}
