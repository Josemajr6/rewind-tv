import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/serie_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Obtenemos el ID del usuario de Google, si no hay, usamos 'invitado_local'
  String get uid => FirebaseAuth.instance.currentUser?.uid ?? 'invitado_local';

  // 1. LEER SERIES (Stream en tiempo real)
  Stream<List<Serie>> getSeries() {
    return _db
        .collection('series')
        .where('uidPropietario', isEqualTo: uid)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Serie.fromFirestore(doc)).toList(),
        );
  }

  // 2. CREAR SERIE
  Future<void> addSerie(Serie serie) async {
    await _db.collection('series').add(serie.toMap());
  }

  // 3. BORRAR SERIE
  Future<void> deleteSerie(String id) async {
    await _db.collection('series').doc(id).delete();
  }
}
