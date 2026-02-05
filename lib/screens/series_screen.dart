import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/firestore_service.dart';
import '../models/serie_model.dart';

class SeriesScreen extends StatefulWidget {
  const SeriesScreen({super.key});

  static const List<String> generos = [
    'Todos',
    'Sci-Fi',
    'Terror',
    'Comedia',
    'Acción',
    'Drama',
    'Anime',
    'Fantasia',
  ];
  // Definimos aquí las plataformas para usarlas al editar
  static const List<String> plataformas = [
    'Netflix',
    'HBO',
    'Disney+',
    'Prime Video',
    'Otras',
  ];

  @override
  State<SeriesScreen> createState() => _SeriesScreenState();
}

class _SeriesScreenState extends State<SeriesScreen> {
  String _filtroGenero = 'Todos';

  @override
  Widget build(BuildContext context) {
    final Color colorTema = const Color(0xFFFF00FF);

    return Column(
      children: [
        // --- BARRA DE FILTROS ---
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: SeriesScreen.generos.length,
            itemBuilder: (context, index) {
              final genero = SeriesScreen.generos[index];
              final isSelected = _filtroGenero == genero;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: ChoiceChip(
                  label: Text(genero),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  selected: isSelected,
                  selectedColor: colorTema,
                  backgroundColor: Colors.transparent,
                  side: BorderSide(
                    color: isSelected ? colorTema : Colors.white24,
                  ),
                  onSelected: (bool selected) {
                    setState(() => _filtroGenero = genero);
                  },
                ),
              );
            },
          ),
        ),

        // --- LISTA ---
        Expanded(
          child: StreamBuilder<List<Serie>>(
            stream: FirestoreService().getSeriesFiltradas(
              genero: _filtroGenero == 'Todos' ? null : _filtroGenero,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(color: colorTema),
                );
              }
              final series = snapshot.data ?? [];

              if (series.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FaIcon(
                        FontAwesomeIcons.ghost,
                        size: 50,
                        color: Colors.white24,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "No hay series aquí",
                        style: TextStyle(color: Colors.white54),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: series.length,
                itemBuilder: (context, index) {
                  final serie = series[index];

                  return Card(
                    color: const Color(0xFF15051D),
                    margin: const EdgeInsets.only(bottom: 15),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(color: colorTema.withOpacity(0.3)),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(15),
                      // --- EDITAR AL TOCAR ---
                      onTap: () => _editarSerie(context, serie),
                      // --- BORRAR AL MANTENER ---
                      onLongPress: () => _borrarSerie(context, serie),

                      title: Text(
                        serie.titulo,
                        style: TextStyle(
                          color: colorTema,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _Etiqueta(
                                texto: serie.genero,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 8),
                              _Etiqueta(
                                texto: serie.plataforma,
                                color: Colors.cyanAccent,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            serie.resena,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 13,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const FaIcon(
                            FontAwesomeIcons.star,
                            color: Colors.yellow,
                            size: 18,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${serie.puntuacion}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
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
    );
  }

  // DIÁLOGO DE EDICIÓN
  void _editarSerie(BuildContext context, Serie serie) {
    final tituloCtrl = TextEditingController(text: serie.titulo);
    final resenaCtrl = TextEditingController(text: serie.resena);
    String genero = SeriesScreen.generos.contains(serie.genero)
        ? serie.genero
        : SeriesScreen.generos[1];
    String plataforma = SeriesScreen.plataformas.contains(serie.plataforma)
        ? serie.plataforma
        : SeriesScreen.plataformas[0];
    int puntuacion = serie.puntuacion;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF100010),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: const BorderSide(color: Color(0xFFFF00FF), width: 2),
          ),
          title: const Text(
            "EDITAR SERIE",
            style: TextStyle(
              color: Color(0xFFFF00FF),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: tituloCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: "Título"),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField(
                  value: plataforma,
                  dropdownColor: const Color(0xFF200520),
                  items: SeriesScreen.plataformas
                      .map(
                        (p) => DropdownMenuItem(
                          value: p,
                          child: Text(
                            p,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => plataforma = v.toString()),
                  decoration: const InputDecoration(labelText: "Plataforma"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: resenaCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: "Reseña"),
                  maxLines: 2,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField(
                  value: genero,
                  dropdownColor: const Color(0xFF200520),
                  items: SeriesScreen.generos
                      .where((g) => g != 'Todos')
                      .map(
                        (g) => DropdownMenuItem(
                          value: g,
                          child: Text(
                            g,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => genero = v.toString()),
                  decoration: const InputDecoration(labelText: "Género"),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField(
                  value: puntuacion,
                  dropdownColor: const Color(0xFF200520),
                  items: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
                      .map(
                        (n) => DropdownMenuItem(
                          value: n,
                          child: Text(
                            "Nota: $n",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => puntuacion = v as int),
                  decoration: const InputDecoration(labelText: "Puntuación"),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF00FF),
              ),
              onPressed: () {
                FirestoreService().updateSerie(serie.id, {
                  'titulo': tituloCtrl.text,
                  'resena': resenaCtrl.text,
                  'genero': genero,
                  'plataforma': plataforma,
                  'puntuacion': puntuacion,
                });
                Navigator.pop(context);
              },
              child: const Text(
                "ACTUALIZAR",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _borrarSerie(BuildContext context, Serie serie) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text(
          "¿Borrar serie?",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text("NO"),
          ),
          TextButton(
            onPressed: () {
              FirestoreService().deleteSerie(serie.id);
              Navigator.pop(c);
            },
            child: const Text(
              "SÍ, BORRAR",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

class _Etiqueta extends StatelessWidget {
  final String texto;
  final Color color;
  const _Etiqueta({required this.texto, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(8),
        color: color.withOpacity(0.1),
      ),
      child: Text(
        texto.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
