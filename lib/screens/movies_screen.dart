import 'package:flutter/material.dart';
import '../models/movie_model.dart';
import '../services/firestore_service.dart';

class MoviesScreen extends StatefulWidget {
  const MoviesScreen({super.key});

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  // Nota mínima para filtrar (null = sin filtro = todas las películas)
  int? _notaMinima = null;

  // Opciones del filtro de nota mínima
  static const List<int?> _opcionesNota = [null, 3, 5, 7, 9];

  @override
  Widget build(BuildContext context) {
    const Color colorPelis = Color(0xFF00FFFF); // Cian neón

    return Scaffold(
      backgroundColor: const Color(0xFF0D0213),
      body: Column(
        children: [
          // ---- Barra de filtro por nota mínima ----
          _barraFiltro(colorPelis),

          // ---- Lista de películas desde Firestore ----
          Expanded(
            child: StreamBuilder<List<Movie>>(
              // Usamos el método filtrado con nota mínima
              stream:
                  FirestoreService().getMoviesFiltradas(notaMinima: _notaMinima),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: colorPelis),
                  );
                }

                final peliculas = snapshot.data!;

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
                        side:
                            const BorderSide(color: colorPelis, width: 0.5),
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
                            IconButton(
                              icon:
                                  const Icon(Icons.edit, color: colorPelis),
                              onPressed: () =>
                                  _mostrarDialogoEditar(context, pelicula),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.redAccent,
                              ),
                              onPressed: () =>
                                  _confirmarEliminar(context, pelicula),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Barra superior con dropdown para filtrar por nota mínima
  Widget _barraFiltro(Color colorPelis) {
    return Container(
      color: const Color(0xFF1A0225),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: Row(
        children: [
          const Text(
            "NOTA MÍN:",
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButton<int?>(
              value: _notaMinima,
              isExpanded: true,
              dropdownColor: const Color(0xFF1A0225),
              underline: Container(height: 1, color: colorPelis),
              items: _opcionesNota.map(
                (nota) => DropdownMenuItem<int?>(
                  value: nota,
                  child: Text(
                    nota == null ? "Todas" : "≥ $nota",
                    style: TextStyle(
                      color: nota == null ? Colors.white70 : colorPelis,
                    ),
                  ),
                ),
              ).toList(),
              onChanged: (valor) {
                setState(() => _notaMinima = valor);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Diálogo para editar película (con validación)
  void _mostrarDialogoEditar(BuildContext context, Movie pelicula) {
    final controladorTitulo = TextEditingController(text: pelicula.titulo);
    final controladorDirector =
        TextEditingController(text: pelicula.director);
    int notaSeleccionada = pelicula.puntuacion;

    // Para mostrar errores de validación
    String? mensajeError;

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
                onChanged: (valor) =>
                    setState(() => notaSeleccionada = valor!),
              ),

              // Mensaje de error si algo no cuadra
              if (mensajeError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    mensajeError!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
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
                // Validación: título obligatorio
                if (controladorTitulo.text.trim().isEmpty) {
                  setState(
                      () => mensajeError = "El título no puede estar vacío");
                  return;
                }
                // Validación: director obligatorio
                if (controladorDirector.text.trim().isEmpty) {
                  setState(
                      () => mensajeError = "El director no puede estar vacío");
                  return;
                }

                // Todo correcto, actualizamos en Firestore
                FirestoreService().updateMovie(pelicula.id!, {
                  'titulo': controladorTitulo.text.trim(),
                  'director': controladorDirector.text.trim(),
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
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
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