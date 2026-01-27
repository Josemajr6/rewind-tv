import 'package:flutter/material.dart';
import '../models/movie_model.dart';
import '../services/firestore_service.dart';

class MoviesScreen extends StatelessWidget {
  const MoviesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Definimos el color cian neón para las Películas
    const Color colorPelis = Color(0xFF00FFFF);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0213), // Fondo oscuro retro
      body: StreamBuilder<List<Movie>>(
        // Escuchamos la colección de películas en tiempo real
        stream: FirestoreService().getMovies(),
        builder: (context, snapshot) {
          // Mientras carga, mostramos el indicador de progreso
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: colorPelis),
            );
          }

          final movies = snapshot.data!;

          return ListView.builder(
            itemCount: movies.length,
            padding: const EdgeInsets.all(15),
            itemBuilder: (context, i) {
              final peli = movies[i];

              // Diseño de la tarjeta de película
              return Card(
                color: Colors.white.withOpacity(0.05), // Fondo sutil
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    color: colorPelis,
                    width: 0.5,
                  ), // Borde neón cian
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  title: Text(
                    peli.titulo.toUpperCase(), // Título siempre en mayúsculas
                    style: const TextStyle(
                      color: colorPelis,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    "${peli.director} • ${peli.puntuacion}/10",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  // Botones de acción unificados (Editar y Borrar)
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white70),
                        onPressed: () => _dialogoEditar(context, peli),
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

  // --- FUNCIÓN PARA EL DIÁLOGO DE EDICIÓN ---
  void _dialogoEditar(BuildContext context, Movie peli) {
    final t1 = TextEditingController(text: peli.titulo);
    final t2 = TextEditingController(text: peli.director);
    int nota = peli.puntuacion;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(
            0xFF1A0225,
          ), // Color de fondo del diálogo
          title: const Text(
            "EDITAR PELÍCULA",
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: t1,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: "Título"),
              ),
              TextField(
                controller: t2,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: "Director"),
              ),
              const SizedBox(height: 10),
              // Selector de Nota
              DropdownButton<int>(
                value: nota,
                isExpanded: true,
                dropdownColor: const Color(0xFF1A0225),
                style: const TextStyle(color: Color(0xFF00FFFF)),
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
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "CANCELAR",
                style: TextStyle(color: Colors.white54),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Actualizamos los datos en Firebase
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
