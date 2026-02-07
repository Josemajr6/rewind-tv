import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/serie_model.dart';
import '../models/movie_model.dart';
import '../models/game_model.dart';

/// servicio para manejar todas las operaciones con firestore
/// aquí está toda la lógica de base de datos para no repetir código
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // obtengo el id del usuario actual (o "invitado" si no hay sesión)
  String get uid => _auth.currentUser?.uid ?? "invitado";

  // ============================================================
  // SERIES
  // ============================================================

  /// traigo las series filtradas y ordenadas
  /// si no pongo género me trae todas
  /// el parámetro descendente controla si va de mayor a menor o al revés
  Stream<List<Serie>> getSeriesFiltradas({
    String? genero,
    bool descendente = true,
  }) {
    Query query = _db.collection('series');

    // si hay filtro de género lo aplico
    if (genero != null && genero != "Todos") {
      query = query.where('genero', isEqualTo: genero);
    }

    return query.snapshots().map((snap) {
      // convierto los documentos a objetos Serie
      final lista = snap.docs
          .map(
            (doc) => Serie.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();

      // ordeno por puntuación según lo que me pidan
      lista.sort(
        (a, b) => descendente
            ? b.puntuacion.compareTo(a.puntuacion) // de 10 a 1
            : a.puntuacion.compareTo(b.puntuacion),
      ); // de 1 a 10

      return lista;
    });
  }

  // añado una nueva serie a firestore
  Future<void> addSerie(Serie serie) async {
    await _db.collection('series').add(serie.toMap());
  }

  // actualizo una serie existente por su id
  Future<void> updateSerie(String id, Map<String, dynamic> datos) async {
    await _db.collection('series').doc(id).update(datos);
  }

  // borro una serie por su id
  Future<void> deleteSerie(String id) async {
    await _db.collection('series').doc(id).delete();
  }

  // ============================================================
  // PELÍCULAS
  // ============================================================

  /// mismo sistema que las series pero para películas
  Stream<List<Movie>> getMoviesFiltradas({
    String? genero,
    bool descendente = true,
  }) {
    Query query = _db.collection('movies');

    if (genero != null && genero != "Todos") {
      query = query.where('genero', isEqualTo: genero);
    }

    return query.snapshots().map((snap) {
      final lista = snap.docs
          .map(
            (doc) => Movie.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();

      lista.sort(
        (a, b) => descendente
            ? b.puntuacion.compareTo(a.puntuacion)
            : a.puntuacion.compareTo(b.puntuacion),
      );

      return lista;
    });
  }

  Future<void> addMovie(Movie peli) async {
    await _db.collection('movies').add(peli.toMap());
  }

  Future<void> updateMovie(String id, Map<String, dynamic> datos) async {
    await _db.collection('movies').doc(id).update(datos);
  }

  Future<void> deleteMovie(String id) async {
    await _db.collection('movies').doc(id).delete();
  }

  // ============================================================
  // JUEGOS
  // ============================================================

  /// para los juegos filtro por plataforma en vez de género
  Stream<List<Game>> getGamesFiltrados({
    String? plataforma,
    bool descendente = true,
  }) {
    Query query = _db.collection('games');

    if (plataforma != null && plataforma != "Todas") {
      query = query.where('plataforma', isEqualTo: plataforma);
    }

    return query.snapshots().map((snap) {
      final lista = snap.docs
          .map(
            (doc) => Game.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();

      lista.sort(
        (a, b) => descendente
            ? b.puntuacion.compareTo(a.puntuacion)
            : a.puntuacion.compareTo(b.puntuacion),
      );

      return lista;
    });
  }

  Future<void> addGame(Game juego) async {
    await _db.collection('games').add(juego.toMap());
  }

  Future<void> updateGame(String id, Map<String, dynamic> datos) async {
    await _db.collection('games').doc(id).update(datos);
  }

  Future<void> deleteGame(String id) async {
    await _db.collection('games').doc(id).delete();
  }
}
