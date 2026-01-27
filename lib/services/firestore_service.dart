import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/serie_model.dart';
import '../models/movie_model.dart';
import '../models/game_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Ayudante para obtener el ID del usuario logueado
  String get uid => _auth.currentUser?.uid ?? "invitado";

  // ==========================================
  // 1. COLECCIÓN: SERIES
  // ==========================================

  Stream<List<Serie>> getSeries() {
    return _db
        .collection('series')
        .snapshots()
        .map(
          (snap) => snap.docs.map((doc) => Serie.fromFirestore(doc)).toList(),
        );
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

  // ==========================================
  // 2. COLECCIÓN: PELÍCULAS (Movies)
  // ==========================================

  Stream<List<Movie>> getMovies() {
    return _db
        .collection('movies')
        .snapshots()
        .map(
          (snap) => snap.docs.map((doc) => Movie.fromFirestore(doc)).toList(),
        );
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

  // ==========================================
  // 3. COLECCIÓN: JUEGOS (Games)
  // ==========================================

  Stream<List<Game>> getGames() {
    return _db
        .collection('games')
        .snapshots()
        .map(
          (snap) => snap.docs.map((doc) => Game.fromFirestore(doc)).toList(),
        );
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
