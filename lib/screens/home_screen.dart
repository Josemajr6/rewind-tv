import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/serie_model.dart';
import '../models/movie_model.dart';
import '../models/game_model.dart';

// Importar las 3 pantallas de colecciones
import 'series_screen.dart';
import 'movies_screen.dart';
import 'games_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Control de la pestaña actual
  int _currentIndex = 0;

  // Colores neón para cada sección
  static const Color colorSerie = Color(0xFFFF00FF); // Magenta
  static const Color colorPeli = Color(0xFF00FFFF); // Cian
  static const Color colorJuego = Color(0xFF00FF66); // Verde

  // Las 3 pantallas de colecciones
  final List<Widget> _paginas = const [
    SeriesScreen(),
    MoviesScreen(),
    GamesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final String nombre = user?.displayName?.split(" ")[0] ?? "INVITADO";

    return Scaffold(
      backgroundColor: const Color(0xFF0D0213),

      // AppBar con logo y botón de salir
      appBar: AppBar(
        backgroundColor: Colors.black,
        leadingWidth: 120,
        leading: Center(
          child: Text(
            "HOLA, $nombre",
            style: TextStyle(
              color: _obtenerColorActual(),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Image.asset('assets/logo.png', height: 30),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const FaIcon(
              FontAwesomeIcons.rightFromBracket,
              color: Colors.white54,
              size: 18,
            ),
            onPressed: () => AuthService().signOut(context),
          ),
        ],
      ),

      // Mostrar la pantalla según la pestaña seleccionada
      body: _paginas[_currentIndex],

      // Navegación inferior con 3 pestañas
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        currentIndex: _currentIndex,
        selectedItemColor: _obtenerColorActual(),
        unselectedItemColor: Colors.white24,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.tv),
            label: 'SERIES',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.film),
            label: 'PELIS',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.gamepad),
            label: 'JUEGOS',
          ),
        ],
      ),

      // Botón flotante para añadir elementos
      floatingActionButton: FloatingActionButton(
        backgroundColor: _obtenerColorActual(),
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () => _abrirDialogoAnadir(context),
      ),
    );
  }

  // Obtener el color según la pestaña actual
  Color _obtenerColorActual() {
    if (_currentIndex == 0) return colorSerie;
    if (_currentIndex == 1) return colorPeli;
    return colorJuego;
  }

  // Abrir el diálogo correspondiente según la pestaña
  void _abrirDialogoAnadir(BuildContext context) {
    if (_currentIndex == 0) {
      _dialogoAnadirSerie(context);
    } else if (_currentIndex == 1) {
      _dialogoAnadirPeli(context);
    } else {
      _dialogoAnadirJuego(context);
    }
  }

  // ========== DIÁLOGO PARA AÑADIR SERIE ==========
  void _dialogoAnadirSerie(BuildContext context) {
    final controladorTitulo = TextEditingController();
    final controladorResena = TextEditingController();
    String generoSeleccionado = SeriesScreen.generos[0];
    int notaSeleccionada = 5;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1A0225),
          title: const Text(
            "NUEVA SERIE",
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
                const SizedBox(height: 10),

                // Selector de género
                DropdownButtonFormField<String>(
                  value: generoSeleccionado,
                  dropdownColor: const Color(0xFF1A0225),
                  style: const TextStyle(color: colorSerie),
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
                const SizedBox(height: 10),

                // Selector de puntuación
                DropdownButtonFormField<int>(
                  value: notaSeleccionada,
                  dropdownColor: const Color(0xFF1A0225),
                  style: const TextStyle(color: colorSerie),
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
                if (controladorTitulo.text.isNotEmpty) {
                  // Añadir serie a Firestore
                  FirestoreService().addSerie(
                    Serie(
                      titulo: controladorTitulo.text,
                      resena: controladorResena.text,
                      genero: generoSeleccionado,
                      puntuacion: notaSeleccionada,
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text("GUARDAR"),
            ),
          ],
        ),
      ),
    );
  }

  // ========== DIÁLOGO PARA AÑADIR PELÍCULA ==========
  void _dialogoAnadirPeli(BuildContext context) {
    final controladorTitulo = TextEditingController();
    final controladorDirector = TextEditingController();
    int notaSeleccionada = 5;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1A0225),
          title: const Text(
            "NUEVA PELÍCULA",
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
              const SizedBox(height: 10),

              // Selector de puntuación
              DropdownButtonFormField<int>(
                value: notaSeleccionada,
                dropdownColor: const Color(0xFF1A0225),
                style: const TextStyle(color: colorPeli),
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
                if (controladorTitulo.text.isNotEmpty) {
                  // Añadir película a Firestore
                  FirestoreService().addMovie(
                    Movie(
                      titulo: controladorTitulo.text,
                      director: controladorDirector.text,
                      puntuacion: notaSeleccionada,
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text("GUARDAR"),
            ),
          ],
        ),
      ),
    );
  }

  // ========== DIÁLOGO PARA AÑADIR JUEGO ==========
  void _dialogoAnadirJuego(BuildContext context) {
    final controladorTitulo = TextEditingController();
    String plataformaSeleccionada = 'PC';
    int notaSeleccionada = 5;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1A0225),
          title: const Text(
            "NUEVO JUEGO",
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

              // Selector de plataforma
              DropdownButtonFormField<String>(
                value: plataformaSeleccionada,
                dropdownColor: const Color(0xFF1A0225),
                style: const TextStyle(color: colorJuego),
                decoration: const InputDecoration(
                  labelText: "Plataforma",
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                items: ['PC', 'PS5', 'Switch', 'Xbox']
                    .map(
                      (plataforma) => DropdownMenuItem(
                        value: plataforma,
                        child: Text(plataforma),
                      ),
                    )
                    .toList(),
                onChanged: (valor) =>
                    setState(() => plataformaSeleccionada = valor!),
              ),
              const SizedBox(height: 10),

              // Selector de puntuación
              DropdownButtonFormField<int>(
                value: notaSeleccionada,
                dropdownColor: const Color(0xFF1A0225),
                style: const TextStyle(color: colorJuego),
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
                if (controladorTitulo.text.isNotEmpty) {
                  // Añadir juego a Firestore
                  FirestoreService().addGame(
                    Game(
                      titulo: controladorTitulo.text,
                      plataforma: plataformaSeleccionada,
                      estado: "Jugando",
                      puntuacion: notaSeleccionada,
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text("GUARDAR"),
            ),
          ],
        ),
      ),
    );
  }
}
