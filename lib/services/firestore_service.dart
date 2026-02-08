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

  /// traigo las series filtradas y ordenadas directamente desde firestore
  /// uso orderBy para que firebase cree automáticamente los índices compuestos
  /// cuando hay filtro + ordenación, firebase necesita un índice (te dará un link para crearlo)
  Stream<List<Serie>> getSeriesFiltradas({
    String? genero,
    bool descendente = true,
  }) {
    Query query = _db.collection('series');

    // si hay filtro de género lo aplico
    if (genero != null && genero != "Todos") {
      query = query.where('genero', isEqualTo: genero);
    }

    // ordeno directamente en firestore (esto crea índices compuestos automáticamente)
    // cuando ejecutes esto por primera vez con filtro, firebase te dará error con un link
    // ese link te lleva directo a crear el índice, solo dale click y listo
    query = query.orderBy('puntuacion', descending: descendente);

    return query.snapshots().map((snap) {
      // ya vienen ordenados desde firestore, solo convierto a objetos
      return snap.docs
          .map(
            (doc) => Serie.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
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

  /// mismo sistema que series pero para películas
  /// firestore crea índice automático cuando combino where + orderBy
  Stream<List<Movie>> getMoviesFiltradas({
    String? genero,
    bool descendente = true,
  }) {
    Query query = _db.collection('movies');

    if (genero != null && genero != "Todos") {
      query = query.where('genero', isEqualTo: genero);
    }

    // ordenación directa en firestore (genera índice compuesto)
    query = query.orderBy('puntuacion', descending: descendente);

    return query.snapshots().map((snap) {
      return snap.docs
          .map(
            (doc) => Movie.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
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
  /// mismo concepto: where + orderBy = índice compuesto automático
  Stream<List<Game>> getGamesFiltrados({
    String? plataforma,
    bool descendente = true,
  }) {
    Query query = _db.collection('games');

    if (plataforma != null && plataforma != "Todas") {
      query = query.where('plataforma', isEqualTo: plataforma);
    }

    // ordenación en firestore para usar índices
    query = query.orderBy('puntuacion', descending: descendente);

    return query.snapshots().map((snap) {
      return snap.docs
          .map(
            (doc) => Game.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
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
