import 'package:flutter/material.dart';
import '../models/serie_model.dart';
import '../services/firestore_service.dart';

class SeriesScreen extends StatelessWidget {
  const SeriesScreen({super.key});

  // Lista de géneros disponibles
  static const List<String> generos = [
    'Acción',
    'Comedia',
    'Drama',
    'Terror',
    'Ciencia Ficción',
    'Suspense',
    'Aventura',
    'Documental',
  ];

  @override
  Widget build(BuildContext context) {
    const Color colorSerie = Color(0xFFFF00FF); // Magenta neón

    return Scaffold(
      backgroundColor: const Color(0xFF0D0213),
      body: StreamBuilder<List<Serie>>(
        // Obtener series en tiempo real desde Firestore
        stream: FirestoreService().getSeries(),
        builder: (context, snapshot) {
          // Mostrar indicador de carga mientras se obtienen los datos
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: colorSerie),
            );
          }

          final series = snapshot.data!;

          // Si no hay series, mostrar mensaje
          if (series.isEmpty) {
            return const Center(
              child: Text(
                'NO HAY SERIES.\nPULSA + PARA AÑADIR',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
            );
          }

          // Lista de series
          return ListView.builder(
            itemCount: series.length,
            padding: const EdgeInsets.all(15),
            itemBuilder: (context, index) {
              final serie = series[index];

              return Card(
                color: Colors.white.withOpacity(0.05),
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: colorSerie, width: 0.5),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ListTile(
                  // Título de la serie
                  title: Text(
                    serie.titulo.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // Género y puntuación
                  subtitle: Text(
                    "${serie.genero} • ${serie.puntuacion}/10",
                    style: const TextStyle(color: Colors.white70),
                  ),

                  // Botones de editar y eliminar
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Botón editar
                      IconButton(
                        icon: const Icon(Icons.edit, color: colorSerie),
                        onPressed: () => _mostrarDialogoEditar(context, serie),
                      ),

                      // Botón eliminar
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _confirmarEliminar(context, serie),
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

  // Diálogo para editar la serie
  void _mostrarDialogoEditar(BuildContext context, Serie serie) {
    final controladorTitulo = TextEditingController(text: serie.titulo);
    final controladorResena = TextEditingController(text: serie.resena);
    String generoSeleccionado = generos.contains(serie.genero)
        ? serie.genero
        : generos[0];
    int notaSeleccionada = serie.puntuacion;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1A0225),
          title: const Text(
            "EDITAR SERIE",
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
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

                // Campo de reseña
                TextField(
                  controller: controladorResena,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Reseña",
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 15),

                // Selector de género
                DropdownButtonFormField<String>(
                  value: generoSeleccionado,
                  dropdownColor: const Color(0xFF1A0225),
                  style: const TextStyle(color: Color(0xFFFF00FF)),
                  decoration: const InputDecoration(
                    labelText: "Género",
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                  items: generos
                      .map(
                        (genero) => DropdownMenuItem(
                          value: genero,
                          child: Text(genero),
                        ),
                      )
                      .toList(),
                  onChanged: (valor) =>
                      setState(() => generoSeleccionado = valor!),
                ),
                const SizedBox(height: 15),

                // Selector de puntuación
                DropdownButtonFormField<int>(
                  value: notaSeleccionada,
                  dropdownColor: const Color(0xFF1A0225),
                  style: const TextStyle(color: Color(0xFFFF00FF)),
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
              ],
            ),
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
                // Actualizar serie en Firestore
                FirestoreService().updateSerie(serie.id!, {
                  'titulo': controladorTitulo.text,
                  'resena': controladorResena.text,
                  'genero': generoSeleccionado,
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
  void _confirmarEliminar(BuildContext context, Serie serie) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A0225),
        title: const Text(
          "CONFIRMAR ELIMINACIÓN",
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          "¿Eliminar '${serie.titulo}'?",
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
              // Eliminar serie de Firestore
              FirestoreService().deleteSerie(serie.id!);
              Navigator.pop(context);
            },
            child: const Text("ELIMINAR"),
          ),
        ],
      ),
    );
  }
}
