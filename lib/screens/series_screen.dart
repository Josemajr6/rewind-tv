import 'package:flutter/material.dart';
import '../models/serie_model.dart';
import '../services/firestore_service.dart';

class SeriesScreen extends StatelessWidget {
  const SeriesScreen({super.key});

  // Lista de géneros para usar en el desplegable (Dropdown)
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
    // Definimos el color magenta neón característico de las Series
    const Color colorSerie = Color(0xFFFF00FF);
    const Color colorCian = Color(0xFF00FFFF);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0213), // Fondo oscuro retro
      body: StreamBuilder<List<Serie>>(
        // Obtenemos los datos de la colección 'series' en tiempo real
        stream: FirestoreService().getSeries(),
        builder: (context, snapshot) {
          // Mientras carga, mostramos el círculo de progreso
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: colorSerie),
            );
          }

          final series = snapshot.data!;

          return ListView.builder(
            itemCount: series.length,
            padding: const EdgeInsets.all(15),
            itemBuilder: (context, i) {
              final s = series[i];

              // Diseño de la tarjeta de cada serie
              return Card(
                color: Colors.white.withOpacity(
                  0.05,
                ), // Fondo sutil transparente
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    color: colorSerie,
                    width: 0.5,
                  ), // Borde neón magenta
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  title: Text(
                    s.titulo
                        .toUpperCase(), // Título en mayúsculas para el look retro
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    "${s.genero} • ${s.puntuacion}/10",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  // Botones de Editar y Borrar unificados
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: colorCian,
                          size: 20,
                        ),
                        onPressed: () => _dialogoEditar(context, s),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.redAccent,
                          size: 20,
                        ),
                        onPressed: () => FirestoreService().deleteSerie(s.id!),
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

  // --- FUNCIÓN PARA EL DIÁLOGO DE EDICIÓN (CRUD: UPDATE) ---
  void _dialogoEditar(BuildContext context, Serie serie) {
    final tTitulo = TextEditingController(text: serie.titulo);
    final tResena = TextEditingController(text: serie.resena);

    // Comprobamos que el género actual exista en nuestra lista oficial
    String generoSel = generos.contains(serie.genero)
        ? serie.genero
        : generos[0];
    int notaSel = serie.puntuacion;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1A0225), // Fondo oscuro del diálogo
          title: const Text(
            "EDITAR SERIE",
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: tTitulo,
                  decoration: const InputDecoration(labelText: "Título"),
                ),
                const SizedBox(height: 10),
                // Campo de reseña con 2 líneas por defecto como pediste
                TextField(
                  controller: tResena,
                  decoration: const InputDecoration(labelText: "Reseña"),
                  maxLines: 2,
                ),
                const SizedBox(height: 15),
                // Desplegable de Género
                DropdownButtonFormField<String>(
                  value: generoSel,
                  dropdownColor: const Color(0xFF1A0225),
                  decoration: const InputDecoration(labelText: "Género"),
                  items: generos
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (v) => setState(() => generoSel = v!),
                ),
                const SizedBox(height: 15),
                // Desplegable de Valoración
                DropdownButtonFormField<int>(
                  value: notaSel,
                  dropdownColor: const Color(0xFF1A0225),
                  decoration: const InputDecoration(labelText: "Valoración"),
                  items: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
                      .map(
                        (n) =>
                            DropdownMenuItem(value: n, child: Text("Nota: $n")),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => notaSel = v!),
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
                // Enviamos los cambios a la base de datos
                FirestoreService().updateSerie(serie.id!, {
                  'titulo': tTitulo.text,
                  'resena': tResena.text,
                  'genero': generoSel,
                  'puntuacion': notaSel,
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
