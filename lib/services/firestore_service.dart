import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/serie_model.dart';
import '../models/movie_model.dart';
import '../models/game_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sacamos el ID del usuario de Google para saber quién está operando.
  String get uid => _auth.currentUser?.uid ?? "invitado";

  // 1. COLECCIÓN DE SERIES (CRUD COMPLETO)

  // LEER: Usamos orderBy para forzar el uso de ÍNDICES en Firebase.
  // Esto hará que las mejores series salgan arriba.
  Stream<List<Serie>> getSeries() {
    return _db
        .collection('series')
        .orderBy('puntuacion', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((doc) => Serie.fromFirestore(doc)).toList(),
        );
  }

  // CREAR: Añadimos una nueva cinta a la estantería virtual.
  Future<void> addSerie(Serie serie) async {
    await _db.collection('series').add(serie.toMap());
  }

  // MODIFICACIÓN DE COLECCIÓN (Punto 1): Editamos campos existentes.
  Future<void> updateSerie(String id, Map<String, dynamic> datos) async {
    await _db.collection('series').doc(id).update(datos);
  }

  // MODIFICACIÓN DE COLECCIÓN (Punto 1): Borramos el documento por completo.
  Future<void> deleteSerie(String id) async {
    await _db.collection('series').doc(id).delete();
  }

  // 2. COLECCIÓN DE PELÍCULAS (CRUD COMPLETO)

  // LEER: Ordenamos por nota. Si al ejecutar esto la app no carga,
  // busca el link en la consola de VS Code para crear el ÍNDICE.
  Stream<List<Movie>> getMovies() {
    return _db
        .collection('movies')
        .orderBy('puntuacion', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((doc) => Movie.fromFirestore(doc)).toList(),
        );
  }

  // CREAR: Guardamos una nueva peli en la colección.
  Future<void> addMovie(Movie peli) async {
    await _db.collection('movies').add(peli.toMap());
  }

  // MODIFICACIÓN DE COLECCIÓN: Actualizamos los datos (título, director o nota).
  Future<void> updateMovie(String id, Map<String, dynamic> datos) async {
    await _db.collection('movies').doc(id).update(datos);
  }

  // MODIFICACIÓN DE COLECCIÓN: Eliminamos la película de la base de datos.
  Future<void> deleteMovie(String id) async {
    await _db.collection('movies').doc(id).delete();
  }

  // 3. COLECCIÓN DE JUEGOS (CRUD COMPLETO)

  // LEER: Obtenemos los juegos en tiempo real con ordenación.
  Stream<List<Game>> getGames() {
    return _db
        .collection('games')
        .orderBy('puntuacion', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((doc) => Game.fromFirestore(doc)).toList(),
        );
  }

  // CREAR: Insertamos un nuevo juego en Firestore.
  Future<void> addGame(Game juego) async {
    await _db.collection('games').add(juego.toMap());
  }

  // MODIFICACIÓN DE COLECCIÓN: Cambiamos plataforma, nota o título.
  Future<void> updateGame(String id, Map<String, dynamic> datos) async {
    await _db.collection('games').doc(id).update(datos);
  }

  // MODIFICACIÓN DE COLECCIÓN: Borrado definitivo del juego.
  Future<void> deleteGame(String id) async {
    await _db.collection('games').doc(id).delete();
  }
}
