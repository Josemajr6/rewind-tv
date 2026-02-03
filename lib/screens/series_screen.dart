import 'package:flutter/material.dart';
import '../models/serie_model.dart';
import '../services/firestore_service.dart';

class SeriesScreen extends StatefulWidget {
  const SeriesScreen({super.key});

  @override
  State<SeriesScreen> createState() => _SeriesScreenState();

  // Lista de géneros disponibles (static para que home_screen pueda usarla)
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
}

class _SeriesScreenState extends State<SeriesScreen> {
  // El genero que tiene el filtro activo (null = sin filtro = todas)
  String? _generoFiltro = null;

  @override
  Widget build(BuildContext context) {
    const Color colorSerie = Color(0xFFFF00FF); // Magenta neón

    return Scaffold(
      backgroundColor: const Color(0xFF0D0213),
      body: Column(
        children: [
          // ---- Barra de filtro por genero ----
          _barraFiltro(colorSerie),

          // ---- Lista de series desde Firestore ----
          Expanded(
            child: StreamBuilder<List<Serie>>(
              // Usamos el método filtrado: si _generoFiltro es null, trae todas
              stream:
                  FirestoreService().getSeriesFiltradas(genero: _generoFiltro),
              builder: (context, snapshot) {
                // Cargando datos...
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: colorSerie),
                  );
                }

                final series = snapshot.data!;

                // Si la lista está vacía, aviso al usuario
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
                        side:
                            const BorderSide(color: colorSerie, width: 0.5),
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
                            IconButton(
                              icon: const Icon(Icons.edit, color: colorSerie),
                              onPressed: () =>
                                  _mostrarDialogoEditar(context, serie),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.redAccent,
                              ),
                              onPressed: () =>
                                  _confirmarEliminar(context, serie),
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

  // Barra superior con dropdown para filtrar por genero
  Widget _barraFiltro(Color colorSerie) {
    return Container(
      color: const Color(0xFF1A0225),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: Row(
        children: [
          const Text(
            "FILTRO:",
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButton<String?>(
              value: _generoFiltro,
              isExpanded: true,
              dropdownColor: const Color(0xFF1A0225),
              underline: Container(height: 1, color: colorSerie),
              // Opción "Todos" para limpiar el filtro
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text(
                    "Todos los géneros",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                ...SeriesScreen.generos.map(
                  (genero) => DropdownMenuItem<String>(
                    value: genero,
                    child: Text(
                      genero,
                      style: TextStyle(color: colorSerie),
                    ),
                  ),
                ),
              ],
              onChanged: (valor) {
                setState(() => _generoFiltro = valor);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Diálogo para editar la serie (con validación)
  void _mostrarDialogoEditar(BuildContext context, Serie serie) {
    final controladorTitulo = TextEditingController(text: serie.titulo);
    final controladorResena = TextEditingController(text: serie.resena);
    String generoSeleccionado =
        SeriesScreen.generos.contains(serie.genero)
            ? serie.genero
            : SeriesScreen.generos[0];
    int notaSeleccionada = serie.puntuacion;

    // Variable para mostrar el error de validación dentro del diálogo
    String? mensajeError;

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
                  items: SeriesScreen.generos
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

                // Mensaje de error si la validación falla
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
                // Validación: el título no puede estar vacío ni ser solo espacios
                if (controladorTitulo.text.trim().isEmpty) {
                  setState(() => mensajeError = "El título no puede estar vacío");
                  return;
                }

                // Actualizar serie en Firestore con datos validados
                FirestoreService().updateSerie(serie.id!, {
                  'titulo': controladorTitulo.text.trim(),
                  'resena': controladorResena.text.trim(),
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
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
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