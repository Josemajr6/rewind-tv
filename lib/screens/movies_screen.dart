import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/firestore_service.dart';
import '../models/movie_model.dart';

class MoviesScreen extends StatefulWidget {
  const MoviesScreen({super.key});

  // AHORA FILTRAMOS POR GÉNERO (Igual que Series)
  static const List<String> generos = [
    'Todos',
    'Sci-Fi',
    'Terror',
    'Comedia',
    'Acción',
    'Drama',
    'Thriller',
    'Fantasia',
  ];

  // Mantenemos la lista de plataformas para el diálogo de añadir/editar
  static const List<String> plataformas = [
    'Netflix',
    'HBO',
    'Disney+',
    'Prime Video',
    'Cine',
    'Otras',
  ];

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  // Estado del filtro: GÉNERO
  String _filtroGenero = 'Todos';

  @override
  Widget build(BuildContext context) {
    final Color colorTema = const Color(0xFF00FFFF);

    return Column(
      children: [
        // --- 1. BARRA DE FILTROS (AHORA GÉNEROS) ---
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: MoviesScreen.generos.length,
            itemBuilder: (context, index) {
              final genero = MoviesScreen.generos[index];
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
                    setState(() {
                      _filtroGenero = genero;
                    });
                  },
                ),
              );
            },
          ),
        ),

        // --- 2. LISTA DE PELIS ---
        Expanded(
          child: StreamBuilder<List<Movie>>(
            // Filtramos por GÉNERO en el servicio
            stream: FirestoreService().getMoviesFiltradas(
              genero: _filtroGenero == 'Todos' ? null : _filtroGenero,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(color: colorTema),
                );
              }
              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    "Error al cargar datos",
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              final movies = snapshot.data ?? [];

              // Estado Vacío
              if (movies.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FaIcon(
                        FontAwesomeIcons.film,
                        size: 50,
                        color: Colors.white24,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "No hay pelis de $_filtroGenero",
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Lista
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: movies.length,
                itemBuilder: (context, index) {
                  final movie = movies[index];

                  return Card(
                    color: const Color(0xFF05181D),
                    margin: const EdgeInsets.only(bottom: 15),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(color: colorTema.withOpacity(0.3)),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(15),
                      onTap: () => _editarPeli(context, movie),
                      onLongPress: () => _borrarPeli(context, movie),

                      title: Text(
                        movie.titulo,
                        style: TextStyle(
                          color: colorTema,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          // Fila de etiquetas: GÉNERO y PLATAFORMA
                          Row(
                            children: [
                              _Etiqueta(
                                texto: movie.genero,
                                color: Colors.white70,
                              ), // Etiqueta Género
                              const SizedBox(width: 8),
                              _Etiqueta(
                                texto: movie.plataforma,
                                color: colorTema,
                              ), // Etiqueta Plataforma
                            ],
                          ),
                          const SizedBox(height: 6),
                          // Director
                          Row(
                            children: [
                              Icon(
                                Icons.person,
                                size: 14,
                                color: Colors.white54,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                movie.director,
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Reseña
                          if (movie.resena.isNotEmpty)
                            Text(
                              movie.resena,
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
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
                            "${movie.puntuacion}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
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

  // --- DIÁLOGO EDITAR ---
  void _editarPeli(BuildContext context, Movie movie) {
    final tituloCtrl = TextEditingController(text: movie.titulo);
    final directorCtrl = TextEditingController(text: movie.director);
    final resenaCtrl = TextEditingController(text: movie.resena);

    // Recuperamos valores o usamos defecto si no existen en la lista
    String plataforma = MoviesScreen.plataformas.contains(movie.plataforma)
        ? movie.plataforma
        : MoviesScreen.plataformas[4];
    String genero = MoviesScreen.generos.contains(movie.genero)
        ? movie.genero
        : MoviesScreen.generos[1]; // Evitar 'Todos' como selección
    int puntuacion = movie.puntuacion;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF001010),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: const BorderSide(color: Color(0xFF00FFFF), width: 2),
          ),
          title: const Text(
            "EDITAR PELÍCULA",
            style: TextStyle(
              color: Color(0xFF00FFFF),
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
                TextField(
                  controller: directorCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: "Director"),
                ),
                const SizedBox(height: 10),
                // Selector GÉNERO
                DropdownButtonFormField(
                  value: genero == 'Todos'
                      ? MoviesScreen.generos[1]
                      : genero, // Seguridad
                  dropdownColor: const Color(0xFF052020),
                  items: MoviesScreen.generos
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
                // Selector PLATAFORMA
                DropdownButtonFormField(
                  value: plataforma,
                  dropdownColor: const Color(0xFF052020),
                  items: MoviesScreen.plataformas
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
                  value: puntuacion,
                  dropdownColor: const Color(0xFF052020),
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
                backgroundColor: const Color(0xFF00FFFF),
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                FirestoreService().updateMovie(movie.id, {
                  'titulo': tituloCtrl.text,
                  'director': directorCtrl.text,
                  'plataforma': plataforma,
                  'genero': genero, // <--- Actualizamos género
                  'resena': resenaCtrl.text,
                  'puntuacion': puntuacion,
                });
                Navigator.pop(context);
              },
              child: const Text("ACTUALIZAR"),
            ),
          ],
        ),
      ),
    );
  }

  void _borrarPeli(BuildContext context, Movie movie) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text(
          "¿Borrar peli?",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text("NO"),
          ),
          TextButton(
            onPressed: () {
              FirestoreService().deleteMovie(movie.id);
              Navigator.pop(c);
            },
            child: const Text("SÍ", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// Widget auxiliar para las etiquetas (reutilizado)
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
