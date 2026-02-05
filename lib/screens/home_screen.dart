import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/serie_model.dart';
import '../models/movie_model.dart';
import '../models/game_model.dart';

// Importo las pantallas de colecciones y la nueva de perfil
import 'series_screen.dart';
import 'movies_screen.dart';
import 'games_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Control de la pestaña actual (0: Series, 1: Pelis, 2: Juegos, 3: Perfil)
  int _currentIndex = 0;

  // Colores neón para cada sección
  static const Color colorSerie = Color(0xFFFF00FF); // Magenta
  static const Color colorPeli = Color(0xFF00FFFF); // Cian
  static const Color colorJuego = Color(0xFF00FF66); // Verde
  static const Color colorPerfil = Color(0xFFFFD700); // Dorado

  // Lista de pantallas
  final List<Widget> _paginas = const [
    SeriesScreen(),
    MoviesScreen(),
    GamesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // 1. Recupero la info del usuario para el saludo de la barra superior.
    final user = AuthService().currentUser;
    // Si hay nombre, cojo la primera palabra, si no, pongo "INVITADO".
    final String nombre =
        user?.displayName?.split(" ")[0].toUpperCase() ?? "INVITADO";

    return Scaffold(
      backgroundColor: const Color(0xFF0D0213),

      // 2. AppBar restaurado con el saludo a la izquierda y logo en el centro.
      appBar: AppBar(
        backgroundColor: Colors.black,
        // Doy anchura al leading para que quepa el texto "HOLA, ..."
        leadingWidth: 120,
        leading: Center(
          child: Text(
            "HOLA, $nombre",
            style: TextStyle(
              // Uso el color de la sección actual para que vaya a juego
              color: _obtenerColorActual(),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // Logo de RewindTV en el centro
        title: Image.asset('assets/logo.png', height: 30),
        centerTitle: true,
        // He dejado las acciones (derecha) vacías porque el botón de salir
        // ahora vive, con más sentido, dentro de la pantalla de Perfil.
      ),

      // Cuerpo de la app (cambia según la pestaña)
      body: _paginas[_currentIndex],

      // Barra de navegación inferior
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        type: BottomNavigationBarType.fixed,
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
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.userAstronaut),
            label: 'PERFIL',
          ),
        ],
      ),

      // Oculto el botón flotante si estoy en el perfil
      floatingActionButton: _currentIndex == 3
          ? null
          : FloatingActionButton(
              backgroundColor: _obtenerColorActual(),
              child: const Icon(Icons.add, color: Colors.black),
              onPressed: () => _abrirDialogoAnadir(context),
            ),
    );
  }

  // ============================================================
  // Helpers y Lógica de Diálogos (Igual que antes)
  // ============================================================

  Color _obtenerColorActual() {
    if (_currentIndex == 0) return colorSerie;
    if (_currentIndex == 1) return colorPeli;
    if (_currentIndex == 2) return colorJuego;
    return colorPerfil;
  }

  void _abrirDialogoAnadir(BuildContext context) {
    if (_currentIndex == 0) {
      _dialogoAnadirSerie(context);
    } else if (_currentIndex == 1) {
      _dialogoAnadirPeli(context);
    } else if (_currentIndex == 2) {
      _dialogoAnadirJuego(context);
    }
  }

  // --- DIÁLOGO SERIES ---
  void _dialogoAnadirSerie(BuildContext context) {
    final controladorTitulo = TextEditingController();
    final controladorResena = TextEditingController();
    String generoSeleccionado = SeriesScreen.generos[0];
    int notaSeleccionada = 5;
    String? mensajeError;

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
                TextField(
                  controller: controladorTitulo,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Título",
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 10),
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
                DropdownButtonFormField<String>(
                  value: generoSeleccionado,
                  dropdownColor: const Color(0xFF1A0225),
                  style: const TextStyle(color: colorSerie),
                  decoration: const InputDecoration(
                    labelText: "Género",
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                  items: SeriesScreen.generos
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (v) => setState(() => generoSeleccionado = v!),
                ),
                const SizedBox(height: 10),
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
                        (n) =>
                            DropdownMenuItem(value: n, child: Text("Nota: $n")),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => notaSeleccionada = v!),
                ),
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
                if (controladorTitulo.text.trim().isEmpty) {
                  setState(
                    () => mensajeError = "El título no puede estar vacío",
                  );
                  return;
                }
                FirestoreService().addSerie(
                  Serie(
                    titulo: controladorTitulo.text.trim(),
                    resena: controladorResena.text.trim(),
                    genero: generoSeleccionado,
                    puntuacion: notaSeleccionada,
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text("GUARDAR"),
            ),
          ],
        ),
      ),
    );
  }

  // --- DIÁLOGO PELIS ---
  void _dialogoAnadirPeli(BuildContext context) {
    final controladorTitulo = TextEditingController();
    final controladorDirector = TextEditingController();
    int notaSeleccionada = 5;
    String? mensajeError;

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
              TextField(
                controller: controladorTitulo,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Título",
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: controladorDirector,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Director",
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(height: 10),
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
                      (n) =>
                          DropdownMenuItem(value: n, child: Text("Nota: $n")),
                    )
                    .toList(),
                onChanged: (v) => setState(() => notaSeleccionada = v!),
              ),
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
                if (controladorTitulo.text.trim().isEmpty) {
                  setState(
                    () => mensajeError = "El título no puede estar vacío",
                  );
                  return;
                }
                if (controladorDirector.text.trim().isEmpty) {
                  setState(
                    () => mensajeError = "El director no puede estar vacío",
                  );
                  return;
                }
                FirestoreService().addMovie(
                  Movie(
                    titulo: controladorTitulo.text.trim(),
                    director: controladorDirector.text.trim(),
                    puntuacion: notaSeleccionada,
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text("GUARDAR"),
            ),
          ],
        ),
      ),
    );
  }

  // --- DIÁLOGO JUEGOS ---
  void _dialogoAnadirJuego(BuildContext context) {
    final controladorTitulo = TextEditingController();
    String plataformaSeleccionada = 'PC';
    int notaSeleccionada = 5;
    String? mensajeError;

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
              TextField(
                controller: controladorTitulo,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Título",
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: plataformaSeleccionada,
                dropdownColor: const Color(0xFF1A0225),
                style: const TextStyle(color: colorJuego),
                decoration: const InputDecoration(
                  labelText: "Plataforma",
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                items: GamesScreen.plataformas
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (v) => setState(() => plataformaSeleccionada = v!),
              ),
              const SizedBox(height: 10),
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
                      (n) =>
                          DropdownMenuItem(value: n, child: Text("Nota: $n")),
                    )
                    .toList(),
                onChanged: (v) => setState(() => notaSeleccionada = v!),
              ),
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
                if (controladorTitulo.text.trim().isEmpty) {
                  setState(
                    () => mensajeError = "El título no puede estar vacío",
                  );
                  return;
                }
                FirestoreService().addGame(
                  Game(
                    titulo: controladorTitulo.text.trim(),
                    plataforma: plataformaSeleccionada,
                    estado: "Jugando",
                    puntuacion: notaSeleccionada,
                  ),
                );
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
