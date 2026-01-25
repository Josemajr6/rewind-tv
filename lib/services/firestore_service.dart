import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/serie_model.dart';
import '../models/episode_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get uid => FirebaseAuth.instance.currentUser?.uid ?? 'invitado_temp';

  Stream<List<Serie>> getSeries() {
    return _db
        .collection('series')
        .where('uidPropietario', isEqualTo: uid)
        .snapshots()
        .map(
          (snap) => snap.docs.map((doc) => Serie.fromFirestore(doc)).toList(),
        );
  }

  Future<void> addSerie(Serie serie) async {
    try {
      await _db.collection('series').add(serie.toMap());
      print("SERIE GUARDADA CORRECTAMENTE");
    } catch (e) {
      print("ERROR AL GUARDAR: $e");
    }
  }

  Future<void> updateSerie(String id, Map<String, dynamic> datos) async {
    await _db.collection('series').doc(id).update(datos);
  }

  Future<void> deleteSerie(String id) async {
    await _db.collection('series').doc(id).delete();
  }

  Stream<List<Episode>> getEpisodes(String serieId) {
    return _db
        .collection('episodes')
        .where('serieId', isEqualTo: serieId)
        .snapshots()
        .map(
          (snap) => snap.docs.map((doc) => Episode.fromFirestore(doc)).toList(),
        );
  }

  // 2. Añadir episodio
  Future<void> addEpisode(Episode episode) async {
    await _db.collection('episodes').add(episode.toMap());
  }

  Future<void> deleteEpisode(String id) async {
    await _db.collection('episodes').doc(id).delete();
  }

  Future<void> updateEpisode(String id, Map<String, dynamic> datos) async {
    await _db.collection('episodes').doc(id).update(datos);
  }
}
