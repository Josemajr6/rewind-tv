import 'package:flutter/material.dart';
import '../models/movie_model.dart';
import '../services/firestore_service.dart';

class MoviesScreen extends StatelessWidget {
  const MoviesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color colorPelis = Color(0xFF00FFFF); // Cian neón

    return Scaffold(
      backgroundColor: const Color(0xFF0D0213),
      body: StreamBuilder<List<Movie>>(
        // Obtener películas en tiempo real desde Firestore
        stream: FirestoreService().getMovies(),
        builder: (context, snapshot) {
          // Mostrar indicador de carga mientras se obtienen los datos
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: colorPelis),
            );
          }

          final peliculas = snapshot.data!;

          // Si no hay películas, mostrar mensaje
          if (peliculas.isEmpty) {
            return const Center(
              child: Text(
                'NO HAY PELÍCULAS.\nPULSA + PARA AÑADIR',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
            );
          }

          // Lista de películas
          return ListView.builder(
            itemCount: peliculas.length,
            padding: const EdgeInsets.all(15),
            itemBuilder: (context, index) {
              final pelicula = peliculas[index];

              return Card(
                color: Colors.white.withOpacity(0.05),
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: colorPelis, width: 0.5),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ListTile(
                  // Título de la película
                  title: Text(
                    pelicula.titulo.toUpperCase(),
                    style: const TextStyle(
                      color: colorPelis,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // Director y puntuación
                  subtitle: Text(
                    "${pelicula.director} • ${pelicula.puntuacion}/10",
                    style: const TextStyle(color: Colors.white70),
                  ),

                  // Botones de editar y eliminar
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Botón editar
                      IconButton(
                        icon: const Icon(Icons.edit, color: colorPelis),
                        onPressed: () =>
                            _mostrarDialogoEditar(context, pelicula),
                      ),

                      // Botón eliminar
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _confirmarEliminar(context, pelicula),
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

  // ========== DIÁLOGO PARA EDITAR PELÍCULA ==========
  void _mostrarDialogoEditar(BuildContext context, Movie pelicula) {
    final controladorTitulo = TextEditingController(text: pelicula.titulo);
    final controladorDirector = TextEditingController(text: pelicula.director);
    int notaSeleccionada = pelicula.puntuacion;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1A0225),
          title: const Text(
            "EDITAR PELÍCULA",
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Campo de título
              TextField(
                controller: controladorTitulo,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Título",
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(height: 10),

              // Campo de director
              TextField(
                controller: controladorDirector,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Director",
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(height: 15),

              // Selector de puntuación
              DropdownButtonFormField<int>(
                value: notaSeleccionada,
                dropdownColor: const Color(0xFF1A0225),
                style: const TextStyle(color: Color(0xFF00FFFF)),
                decoration: const InputDecoration(
                  labelText: "Puntuación",
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                items: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
                    .map(
                      (nota) => DropdownMenuItem(
                        value: nota,
                        child: Text("Nota: $nota"),
                      ),
                    )
                    .toList(),
                onChanged: (valor) => setState(() => notaSeleccionada = valor!),
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
                // Actualizar película en Firestore
                FirestoreService().updateMovie(pelicula.id!, {
                  'titulo': controladorTitulo.text,
                  'director': controladorDirector.text,
                  'puntuacion': notaSeleccionada,
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

  // Diálogo para confirmar antes de eliminar
  void _confirmarEliminar(BuildContext context, Movie pelicula) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A0225),
        title: const Text(
          "CONFIRMAR ELIMINACIÓN",
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          "¿Eliminar '${pelicula.titulo}'?",
          style: const TextStyle(color: Colors.white70),
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              // Eliminar película de Firestore
              FirestoreService().deleteMovie(pelicula.id!);
              Navigator.pop(context);
            },
            child: const Text("ELIMINAR"),
          ),
        ],
      ),
    );
  }
}
