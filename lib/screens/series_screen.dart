import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/firestore_service.dart';
import '../models/serie_model.dart';

/// pantalla de series donde se listan, filtran y ordenan
class SeriesScreen extends StatefulWidget {
  const SeriesScreen({super.key});

  // listas estáticas que uso en toda la pantalla
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
  // controlo qué género está seleccionado
  String _filtroGenero = 'Todos';

  // true = de mayor a menor, false = de menor a mayor
  bool _ordenDescendente = true;

  @override
  Widget build(BuildContext context) {
    final Color colorTema = const Color(0xFFFF00FF); // magenta neón

    return Column(
      children: [
        // -- chips de filtro por género --
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
                  onSelected: (_) => setState(() => _filtroGenero = genero),
                ),
              );
            },
          ),
        ),

        // -- botón para cambiar orden ascendente/descendente --
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: () =>
                    setState(() => _ordenDescendente = !_ordenDescendente),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colorTema.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colorTema.withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _ordenDescendente
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        color: colorTema,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _ordenDescendente ? "Mayor a menor" : "Menor a mayor",
                        style: TextStyle(
                          color: colorTema,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // -- lista de series desde firestore --
        Expanded(
          child: StreamBuilder<List<Serie>>(
            // escucho cambios en tiempo real de firestore
            stream: FirestoreService().getSeriesFiltradas(
              genero: _filtroGenero == 'Todos' ? null : _filtroGenero,
              descendente: _ordenDescendente,
            ),
            builder: (context, snapshot) {
              // mientras carga muestro un spinner
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(color: colorTema),
                );
              }

              final series = snapshot.data ?? [];

              // si no hay series muestro un mensaje
              if (series.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.tv_off, size: 50, color: Colors.white24),
                      SizedBox(height: 20),
                      Text(
                        "No hay series aquí",
                        style: TextStyle(color: Colors.white54),
                      ),
                    ],
                  ),
                );
              }

              // muestro la lista de series
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
                      // tap normal abre el diálogo de editar
                      onTap: () => _mostrarDialogoEditar(context, serie),
                      // mantener presionado pregunta si quiero borrar
                      onLongPress: () => _confirmarBorrar(context, serie),
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
                          // muestro género y plataforma en una línea
                          Text(
                            "${serie.genero} • ${serie.plataforma}",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          // si hay reseña la muestro
                          if (serie.resena.isNotEmpty) ...[
                            const SizedBox(height: 8),
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
                        ],
                      ),
                      // estrella con la puntuación
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.star,
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

  /// muestro el diálogo para editar una serie
  /// incluye validación de campos
  void _mostrarDialogoEditar(BuildContext context, Serie serie) {
    final formKey = GlobalKey<FormState>();
    final tituloCtrl = TextEditingController(text: serie.titulo);
    final resenaCtrl = TextEditingController(text: serie.resena);
    String genero = serie.genero;
    String plataforma = serie.plataforma;
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
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // campo de título con validación
                  TextFormField(
                    controller: tituloCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: "Título *"),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty)
                        return 'Título obligatorio';
                      if (v.trim().length < 2) return 'Mínimo 2 caracteres';
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),

                  // selector de plataforma
                  DropdownButtonFormField(
                    value: plataforma,
                    dropdownColor: const Color(0xFF200520),
                    decoration: const InputDecoration(labelText: "Plataforma"),
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
                  ),
                  const SizedBox(height: 10),

                  // campo de reseña (opcional pero con mínimo si se rellena)
                  TextFormField(
                    controller: resenaCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: "Reseña"),
                    maxLines: 2,
                    validator: (v) {
                      if (v != null &&
                          v.trim().isNotEmpty &&
                          v.trim().length < 5) {
                        return 'Mínimo 5 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),

                  // selector de género
                  DropdownButtonFormField(
                    value: genero,
                    dropdownColor: const Color(0xFF200520),
                    decoration: const InputDecoration(labelText: "Género"),
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
                  ),
                  const SizedBox(height: 10),

                  // selector de puntuación del 1 al 10
                  DropdownButtonFormField(
                    value: puntuacion,
                    dropdownColor: const Color(0xFF200520),
                    decoration: const InputDecoration(labelText: "Puntuación"),
                    items: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
                        .map(
                          (n) => DropdownMenuItem(
                            value: n,
                            child: Text(
                              "$n",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => puntuacion = v as int),
                  ),
                ],
              ),
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
                // solo guardo si pasa todas las validaciones
                if (formKey.currentState!.validate()) {
                  FirestoreService().updateSerie(serie.id, {
                    'titulo': tituloCtrl.text.trim(),
                    'resena': resenaCtrl.text.trim(),
                    'genero': genero,
                    'plataforma': plataforma,
                    'puntuacion': puntuacion,
                  });
                  Navigator.pop(context);

                  // muestro mensaje de confirmación
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Serie actualizada'),
                      backgroundColor: Color(0xFF00FF66),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Text(
                "GUARDAR",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// pregunto antes de borrar para evitar errores
  void _confirmarBorrar(BuildContext context, Serie serie) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text(
          "¿Borrar serie?",
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '¿Eliminar "${serie.titulo}"?',
          style: const TextStyle(color: Colors.white70),
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

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Serie eliminada'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text("SÍ", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
