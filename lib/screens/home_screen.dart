import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../models/serie_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF120512), // Fondo oscuro coherente
      appBar: AppBar(
        title: const Text(
          "REWIND TV",
          style: TextStyle(
            letterSpacing: 3,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          // BOTÓN CERRAR SESIÓN (Arreglado para salir de invitado o Google)
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF00FFFF)),
            onPressed: () => AuthService().signOut(context),
          ),
        ],
      ),
      body: StreamBuilder<List<Serie>>(
        stream: FirestoreService().getSeries(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                "Error al cargar datos",
                style: TextStyle(color: Colors.white),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF00FFFF)),
            );
          }

          final series = snapshot.data!;

          if (series.isEmpty) {
            return const Center(
              child: Text(
                "No hay series guardadas.\n¡Añade la primera!",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView.builder(
            itemCount: series.length,
            padding: const EdgeInsets.only(top: 10, bottom: 80),
            itemBuilder: (context, index) {
              final serie = series[index];
              return Card(
                color: Colors.white.withOpacity(0.05),
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Color(0xFF9D089D), width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 5,
                  ),
                  title: Text(
                    serie.titulo.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    "${serie.genero} • ${serie.temporadas} Temporadas",
                    style: const TextStyle(
                      color: Color(0xFF00FFFF),
                      fontSize: 12,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete_sweep,
                      color: Colors.redAccent,
                    ),
                    onPressed: () => FirestoreService().deleteSerie(serie.id!),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF9D089D),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
        onPressed: () => _dialogoNuevaSerie(context),
      ),
    );
  }

  // Cuadro de diálogo minimalista para añadir series
  void _dialogoNuevaSerie(BuildContext context) {
    final titleController = TextEditingController();
    final genreController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A0A1A),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0xFF00FFFF)),
        ),
        title: const Text(
          "AÑADIR SERIE",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Nombre de la serie",
                labelStyle: TextStyle(color: Colors.white38),
              ),
            ),
            TextField(
              controller: genreController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Género",
                labelStyle: TextStyle(color: Colors.white38),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "CANCELAR",
              style: TextStyle(color: Colors.white38),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9D089D),
            ),
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                FirestoreService().addSerie(
                  Serie(
                    titulo: titleController.text,
                    genero: genreController.text.isEmpty
                        ? "Desconocido"
                        : genreController.text,
                    temporadas: 1,
                    puntuacion: 5,
                    estado: "viendo",
                    uidPropietario: FirestoreService().uid,
                  ),
                );
                Navigator.pop(context);
              }
            },
            child: const Text("GUARDAR"),
          ),
        ],
      ),
    );
  }
}
