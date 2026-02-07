import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/firestore_service.dart';
import '../models/movie_model.dart';

/// pantalla donde se gestionan las películas
class MoviesScreen extends StatefulWidget {
  const MoviesScreen({super.key});

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
  String _filtroGenero = 'Todos';
  bool _ordenDescendente = true;

  @override
  Widget build(BuildContext context) {
    final Color colorTema = const Color(0xFF00FFFF); // cian neón

    return Column(
      children: [
        // -- chips de filtro por género --
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
                  onSelected: (_) => setState(() => _filtroGenero = genero),
                ),
              );
            },
          ),
        ),

        // -- botón de ordenación --
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

        // -- lista de películas --
        Expanded(
          child: StreamBuilder<List<Movie>>(
            stream: FirestoreService().getMoviesFiltradas(
              genero: _filtroGenero == 'Todos' ? null : _filtroGenero,
              descendente: _ordenDescendente,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(color: colorTema),
                );
              }

              final movies = snapshot.data ?? [];

              if (movies.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.movie_outlined,
                        size: 50,
                        color: Colors.white24,
                      ),
                      SizedBox(height: 20),
                      Text(
                        "No hay películas aquí",
                        style: TextStyle(color: Colors.white54),
                      ),
                    ],
                  ),
                );
              }

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
                      onTap: () => _mostrarDialogoEditar(context, movie),
                      onLongPress: () => _confirmarBorrar(context, movie),
                      title: Text(
                        movie.titulo,
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
                          // género y plataforma
                          Text(
                            "${movie.genero} • ${movie.plataforma}",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // director
                          Text(
                            "Dir: ${movie.director}",
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                            ),
                          ),
                          // reseña si existe
                          if (movie.resena.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              movie.resena,
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
                            "${movie.puntuacion}",
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

  /// diálogo para editar película con validación
  void _mostrarDialogoEditar(BuildContext context, Movie movie) {
    final formKey = GlobalKey<FormState>();
    final tituloCtrl = TextEditingController(text: movie.titulo);
    final directorCtrl = TextEditingController(text: movie.director);
    final resenaCtrl = TextEditingController(text: movie.resena);
    String genero = movie.genero;
    String plataforma = movie.plataforma;
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
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // título (obligatorio)
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

                  // director (obligatorio)
                  TextFormField(
                    controller: directorCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: "Director *"),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty)
                        return 'Director obligatorio';
                      if (v.trim().length < 3) return 'Mínimo 3 caracteres';
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),

                  // género
                  DropdownButtonFormField(
                    value: genero,
                    dropdownColor: const Color(0xFF052020),
                    decoration: const InputDecoration(labelText: "Género"),
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
                  ),
                  const SizedBox(height: 10),

                  // plataforma
                  DropdownButtonFormField(
                    value: plataforma,
                    dropdownColor: const Color(0xFF052020),
                    decoration: const InputDecoration(labelText: "Plataforma"),
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
                  ),
                  const SizedBox(height: 10),

                  // reseña (opcional)
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

                  // puntuación
                  DropdownButtonFormField(
                    value: puntuacion,
                    dropdownColor: const Color(0xFF052020),
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
                backgroundColor: const Color(0xFF00FFFF),
              ),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  FirestoreService().updateMovie(movie.id, {
                    'titulo': tituloCtrl.text.trim(),
                    'director': directorCtrl.text.trim(),
                    'genero': genero,
                    'plataforma': plataforma,
                    'resena': resenaCtrl.text.trim(),
                    'puntuacion': puntuacion,
                  });
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Película actualizada'),
                      backgroundColor: Color(0xFF00FF66),
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

  void _confirmarBorrar(BuildContext context, Movie movie) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text(
          "¿Borrar película?",
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '¿Eliminar "${movie.titulo}"?',
          style: const TextStyle(color: Colors.white70),
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

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Película eliminada'),
                  backgroundColor: Colors.red,
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
