import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/serie_model.dart';
import '../models/movie_model.dart';
import '../models/game_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser?.uid ?? "invitado";

  // ============================================================
  // SERIES
  // ============================================================
  Stream<List<Serie>> getSeries() {
    return _db
        .collection('series')
        .orderBy('puntuacion', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => Serie.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Stream<List<Serie>> getSeriesFiltradas({String? genero}) {
    Query query = _db.collection('series');
    if (genero != null && genero != "Todos") {
      query = query.where('genero', isEqualTo: genero);
    }
    return query.snapshots().map((snap) {
      final lista = snap.docs
          .map(
            (doc) => Serie.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
      lista.sort((a, b) => b.puntuacion.compareTo(a.puntuacion));
      return lista;
    });
  }

  Future<void> addSerie(Serie serie) async {
    await _db.collection('series').add(serie.toMap());
  }

  Future<void> updateSerie(String id, Map<String, dynamic> datos) async {
    await _db.collection('series').doc(id).update(datos);
  }

  Future<void> deleteSerie(String id) async {
    await _db.collection('series').doc(id).delete();
  }

  // ============================================================
  // PELÍCULAS (ACTUALIZADO A GÉNERO)
  // ============================================================

  Stream<List<Movie>> getMovies() {
    return _db
        .collection('movies')
        .orderBy('puntuacion', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => Movie.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // AHORA FILTRA POR GÉNERO, NO POR PLATAFORMA
  Stream<List<Movie>> getMoviesFiltradas({String? genero}) {
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

      lista.sort((a, b) => b.puntuacion.compareTo(a.puntuacion));

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
  Stream<List<Game>> getGames() {
    return _db
        .collection('games')
        .orderBy('puntuacion', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => Game.fromMap(doc.data(), doc.id)).toList(),
        );
  }

  Stream<List<Game>> getGamesFiltrados({String? plataforma}) {
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
      lista.sort((a, b) => b.puntuacion.compareTo(a.puntuacion));
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
