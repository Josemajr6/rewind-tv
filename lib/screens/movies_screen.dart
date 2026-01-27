import 'package:flutter/material.dart';
import '../models/movie_model.dart';
import '../services/firestore_service.dart';

class MoviesScreen extends StatelessWidget {
  const MoviesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color cian = Color(0xFF00FFFF);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0213),
      body: StreamBuilder<List<Movie>>(
        stream: FirestoreService().getMovies(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: cian));
          }
          final movies = snapshot.data!;
          return ListView.builder(
            itemCount: movies.length,
            padding: const EdgeInsets.all(15),
            itemBuilder: (context, i) {
              final peli = movies[i];
              return Card(
                color: Colors.white10,
                child: ListTile(
                  title: Text(
                    peli.titulo,
                    style: const TextStyle(
                      color: cian,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text("${peli.director} • ${peli.puntuacion}/10"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white70),
                        onPressed: () => _dialogoEditarPeli(context, peli),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () =>
                            FirestoreService().deleteMovie(peli.id!),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _dialogoEditarPeli(BuildContext context, Movie peli) {
    final t1 = TextEditingController(text: peli.titulo);
    final t2 = TextEditingController(text: peli.director);
    int nota = peli.puntuacion;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("EDITAR PELÍCULA"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: t1,
                decoration: const InputDecoration(labelText: "Título"),
              ),
              TextField(
                controller: t2,
                decoration: const InputDecoration(labelText: "Director"),
              ),
              DropdownButton<int>(
                value: nota,
                items: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
                    .map(
                      (n) =>
                          DropdownMenuItem(value: n, child: Text("Nota: $n")),
                    )
                    .toList(),
                onChanged: (v) => setState(() => nota = v!),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                FirestoreService().updateMovie(peli.id!, {
                  'titulo': t1.text,
                  'director': t2.text,
                  'puntuacion': nota,
                });
                Navigator.pop(context);
              },
              child: const Text("GUARDAR"),
            ),
          ],
        ),
      ),
    );
  }
}
