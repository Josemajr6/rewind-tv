import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/serie_model.dart';
import '../models/movie_model.dart';
import '../models/game_model.dart';

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
  int _currentIndex = 0;

  // Colores Neón por sección
  static const Color colorSerie = Color(0xFFFF00FF);
  static const Color colorPeli = Color(0xFF00FFFF);
  static const Color colorJuego = Color(0xFF00FF66);
  static const Color colorPerfil = Color(0xFFFFD700);

  // Listas de Plataformas para los diálogos
  final List<String> _plataformasSeries = const [
    'Netflix',
    'HBO',
    'Disney+',
    'Prime Video',
    'Otras',
  ];
  final List<String> _plataformasPelis = const [
    'Netflix',
    'HBO',
    'Disney+',
    'Prime Video',
    'Cine',
    'Otras',
  ];

  final List<Widget> _paginas = const [
    SeriesScreen(),
    MoviesScreen(),
    GamesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final String nombre =
        user?.displayName?.split(" ")[0].toUpperCase() ?? "INVITADO";
    final Color colorActual = _obtenerColorActual();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      // --- APPBAR ---
      appBar: AppBar(
        leadingWidth: 150,
        leading: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(
              "Hola, $nombre",
              style: TextStyle(
                color: colorActual,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                shadows: [
                  Shadow(color: colorActual.withOpacity(0.8), blurRadius: 10),
                ],
              ),
            ),
          ),
        ),
        title: Image.asset('assets/logo.png', height: 32),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: _paginas[_currentIndex],

      // --- BARRA INFERIOR ---
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border(top: BorderSide(color: colorActual, width: 2.0)),
          boxShadow: [
            BoxShadow(
              color: colorActual.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          selectedItemColor: colorActual,
          unselectedItemColor: Colors.grey.shade700,
          selectedFontSize: 12,
          unselectedFontSize: 10,
          selectedIconTheme: const IconThemeData(size: 26),
          unselectedIconTheme: const IconThemeData(size: 20),
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
      ),

      // --- FAB ---
      floatingActionButton: _currentIndex == 3
          ? null
          : Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colorActual.withOpacity(0.5),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: FloatingActionButton(
                backgroundColor: colorActual,
                child: const Icon(Icons.add, color: Colors.black),
                onPressed: () => _abrirDialogoAnadir(context),
              ),
            ),
    );
  }

  Color _obtenerColorActual() {
    if (_currentIndex == 0) return colorSerie;
    if (_currentIndex == 1) return colorPeli;
    if (_currentIndex == 2) return colorJuego;
    return colorPerfil;
  }

  void _abrirDialogoAnadir(BuildContext context) {
    if (_currentIndex == 0)
      _dialogoAnadirSerie(context);
    else if (_currentIndex == 1)
      _dialogoAnadirPeli(context);
    else if (_currentIndex == 2)
      _dialogoAnadirJuego(context);
  }

  // ============================================================
  // DIÁLOGOS DE CREACIÓN (SERIES, PELIS, JUEGOS)
  // ============================================================

  // --- SERIES ---
  void _dialogoAnadirSerie(BuildContext context) {
    final controladorTitulo = TextEditingController();
    final controladorResena = TextEditingController();
    String generoSeleccionado = SeriesScreen.generos[1]; // Evitar 'Todos'
    String plataformaSeleccionada = _plataformasSeries[0];
    int notaSeleccionada = 5;
    String? mensajeError;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF100010),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: colorSerie, width: 2),
          ),
          shadowColor: colorSerie.withOpacity(0.6),
          elevation: 25,
          title: Text(
            "NUEVA SERIE",
            style: TextStyle(
              color: colorSerie,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
            textAlign: TextAlign.center,
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
                    prefixIcon: Icon(Icons.tv, color: Colors.white54),
                  ),
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: plataformaSeleccionada,
                  dropdownColor: const Color(0xFF200520),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Plataforma",
                    prefixIcon: Icon(Icons.live_tv, color: Colors.white54),
                  ),
                  items: _plataformasSeries
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (v) => setState(() => plataformaSeleccionada = v!),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: controladorResena,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Reseña",
                    prefixIcon: Icon(Icons.edit, color: Colors.white54),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: generoSeleccionado,
                  dropdownColor: const Color(0xFF200520),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: "Género"),
                  // Filtramos 'Todos' para que no se pueda elegir al crear
                  items: SeriesScreen.generos
                      .where((g) => g != 'Todos')
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (v) => setState(() => generoSeleccionado = v!),
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<int>(
                  value: notaSeleccionada,
                  dropdownColor: const Color(0xFF200520),
                  style: const TextStyle(
                    color: colorSerie,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(labelText: "Puntuación"),
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
                    padding: const EdgeInsets.only(top: 15),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: colorSerie,
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                if (controladorTitulo.text.trim().isEmpty) {
                  setState(() => mensajeError = "Pon un título");
                  return;
                }
                FirestoreService().addSerie(
                  Serie(
                    titulo: controladorTitulo.text.trim(),
                    resena: controladorResena.text.trim(),
                    genero: generoSeleccionado,
                    puntuacion: notaSeleccionada,
                    plataforma: plataformaSeleccionada,
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

  // --- PELIS (ACTUALIZADO CON GÉNERO) ---
  void _dialogoAnadirPeli(BuildContext context) {
    final controladorTitulo = TextEditingController();
    final controladorDirector = TextEditingController();
    final controladorResena = TextEditingController();
    String plataformaSeleccionada = _plataformasPelis[4]; // Default 'Cine'
    String generoSeleccionado =
        MoviesScreen.generos[1]; // Default 'Sci-Fi' (evitamos 'Todos')
    int notaSeleccionada = 5;
    String? mensajeError;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF001010),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: colorPeli, width: 2),
          ),
          shadowColor: colorPeli.withOpacity(0.6),
          elevation: 25,
          title: Text(
            "NUEVA PELÍCULA",
            style: TextStyle(
              color: colorPeli,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
            textAlign: TextAlign.center,
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
                    prefixIcon: Icon(Icons.movie, color: Colors.white54),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: controladorDirector,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Director",
                    prefixIcon: Icon(Icons.person, color: Colors.white54),
                  ),
                ),
                const SizedBox(height: 15),
                // NUEVO: Selector de GÉNERO
                DropdownButtonFormField<String>(
                  value: generoSeleccionado,
                  dropdownColor: const Color(0xFF052020),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: "Género"),
                  // Importante: Filtramos 'Todos'
                  items: MoviesScreen.generos
                      .where((g) => g != 'Todos')
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (v) => setState(() => generoSeleccionado = v!),
                ),
                const SizedBox(height: 15),
                // Selector de PLATAFORMA
                DropdownButtonFormField<String>(
                  value: plataformaSeleccionada,
                  dropdownColor: const Color(0xFF052020),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Plataforma",
                    prefixIcon: Icon(Icons.theaters, color: Colors.white54),
                  ),
                  items: _plataformasPelis
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (v) => setState(() => plataformaSeleccionada = v!),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: controladorResena,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Reseña",
                    prefixIcon: Icon(Icons.edit, color: Colors.white54),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<int>(
                  value: notaSeleccionada,
                  dropdownColor: const Color(0xFF052020),
                  style: const TextStyle(
                    color: colorPeli,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(labelText: "Puntuación"),
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
                    padding: const EdgeInsets.only(top: 15),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: colorPeli,
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                if (controladorTitulo.text.trim().isEmpty) {
                  setState(() => mensajeError = "Título obligatorio");
                  return;
                }
                if (controladorDirector.text.trim().isEmpty) {
                  setState(() => mensajeError = "Director obligatorio");
                  return;
                }
                FirestoreService().addMovie(
                  Movie(
                    titulo: controladorTitulo.text.trim(),
                    director: controladorDirector.text.trim(),
                    puntuacion: notaSeleccionada,
                    plataforma: plataformaSeleccionada,
                    genero: generoSeleccionado, // <--- GUARDAMOS GÉNERO
                    resena: controladorResena.text.trim(),
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

  // --- JUEGOS ---
  void _dialogoAnadirJuego(BuildContext context) {
    final controladorTitulo = TextEditingController();
    final controladorResena = TextEditingController();
    String plataformaSeleccionada = 'PC';
    int notaSeleccionada = 5;
    String? mensajeError;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF001005),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: colorJuego, width: 2),
          ),
          shadowColor: colorJuego.withOpacity(0.6),
          elevation: 25,
          title: Text(
            "NUEVO JUEGO",
            style: TextStyle(
              color: colorJuego,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
            textAlign: TextAlign.center,
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
                    prefixIcon: Icon(Icons.gamepad, color: Colors.white54),
                  ),
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: plataformaSeleccionada,
                  dropdownColor: const Color(0xFF052010),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Plataforma",
                    prefixIcon: Icon(Icons.computer, color: Colors.white54),
                  ),
                  items: GamesScreen.plataformas
                      .where((p) => p != 'Todas')
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (v) => setState(() => plataformaSeleccionada = v!),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: controladorResena,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Reseña",
                    prefixIcon: Icon(Icons.edit, color: Colors.white54),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<int>(
                  value: notaSeleccionada,
                  dropdownColor: const Color(0xFF052010),
                  style: const TextStyle(
                    color: colorJuego,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    labelText: "Puntuación",
                    prefixIcon: Icon(Icons.star, color: Colors.white54),
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
                    padding: const EdgeInsets.only(top: 15),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: colorJuego,
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                if (controladorTitulo.text.trim().isEmpty) {
                  setState(() => mensajeError = "Título obligatorio");
                  return;
                }
                FirestoreService().addGame(
                  Game(
                    titulo: controladorTitulo.text.trim(),
                    plataforma: plataformaSeleccionada,
                    estado: "Jugando",
                    puntuacion: notaSeleccionada,
                    resena: controladorResena.text.trim(),
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
