import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/serie_model.dart';
import '../models/movie_model.dart';
import '../models/game_model.dart';

// Asegúrate de tener estos archivos creados en tu carpeta screens
import 'series_screen.dart';
import 'movies_screen.dart';
import 'games_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Índice de la pestaña actual
  int _currentIndex = 0;

  // Colores neón para cada categoría
  static const Color colorSerie = Color(0xFFFF00FF); // Magenta
  static const Color colorPeli = Color(0xFF00FFFF); // Cian
  static const Color colorJuego = Color(0xFF00FF66); // Verde

  // Lista de las 3 páginas (Imprescindible tener 3 para evitar el RangeError)
  final List<Widget> _paginas = [
    const SeriesScreen(),
    const MoviesScreen(),
    const GamesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final String nombre = user?.displayName?.split(" ")[0] ?? "INVITADO";

    return Scaffold(
      backgroundColor: const Color(0xFF0D0213),
      appBar: AppBar(
        backgroundColor: Colors.black,
        leadingWidth: 120,
        leading: Center(
          child: Text(
            "HOLA, $nombre".toUpperCase(),
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

      // Muestra la pantalla según la pestaña
      body: _paginas[_currentIndex],

      // Menú inferior
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

      // Botón flotante para crear (He cambiado el nombre de la función a 'Anadir')
      floatingActionButton: FloatingActionButton(
        backgroundColor: _obtenerColorActual(),
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () => _abrirDialogoAnadir(context),
      ),
    );
  }

  // --- LÓGICA INTERNA (SIN CARACTERES ESPECIALES) ---

  Color _obtenerColorActual() {
    if (_currentIndex == 0) return colorSerie;
    if (_currentIndex == 1) return colorPeli;
    return colorJuego;
  }

  void _abrirDialogoAnadir(BuildContext context) {
    if (_currentIndex == 0)
      _dialogoAnadirSerie(context);
    else if (_currentIndex == 1)
      _dialogoAnadirPeli(context);
    else
      _dialogoAnadirJuego(context);
  }

  // 1. DIÁLOGO SERIE
  void _dialogoAnadirSerie(BuildContext context) {
    final t1 = TextEditingController();
    final t2 = TextEditingController();
    String gen = SeriesScreen.generos[0];
    int nota = 5;

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
                  controller: t1,
                  decoration: const InputDecoration(labelText: "Título"),
                ),
                TextField(
                  controller: t2,
                  decoration: const InputDecoration(labelText: "Reseña"),
                  maxLines: 2,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: gen,
                  dropdownColor: const Color(0xFF1A0225),
                  items: SeriesScreen.generos
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (v) => setState(() => gen = v!),
                  decoration: const InputDecoration(labelText: "Género"),
                ),
                DropdownButtonFormField<int>(
                  value: nota,
                  dropdownColor: const Color(0xFF1A0225),
                  items: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
                      .map(
                        (n) =>
                            DropdownMenuItem(value: n, child: Text("Nota: $n")),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => nota = v!),
                  decoration: const InputDecoration(labelText: "Puntuación"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCELAR"),
            ),
            ElevatedButton(
              onPressed: () {
                if (t1.text.isNotEmpty) {
                  FirestoreService().addSerie(
                    Serie(
                      titulo: t1.text,
                      resena: t2.text,
                      genero: gen,
                      puntuacion: nota,
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

  // 2. DIÁLOGO PELÍCULA
  void _dialogoAnadirPeli(BuildContext context) {
    final t1 = TextEditingController();
    final t2 = TextEditingController();
    int nota = 5;

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
                controller: t1,
                decoration: const InputDecoration(labelText: "Título"),
              ),
              TextField(
                controller: t2,
                decoration: const InputDecoration(labelText: "Director"),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<int>(
                value: nota,
                dropdownColor: const Color(0xFF1A0225),
                items: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
                    .map(
                      (n) =>
                          DropdownMenuItem(value: n, child: Text("Nota: $n")),
                    )
                    .toList(),
                onChanged: (v) => setState(() => nota = v!),
                decoration: const InputDecoration(labelText: "Nota"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCELAR"),
            ),
            ElevatedButton(
              onPressed: () {
                if (t1.text.isNotEmpty) {
                  FirestoreService().addMovie(
                    Movie(titulo: t1.text, director: t2.text, puntuacion: nota),
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

  // 3. DIÁLOGO JUEGO
  void _dialogoAnadirJuego(BuildContext context) {
    final t1 = TextEditingController();
    String plat = 'PC';
    int nota = 5;

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
                controller: t1,
                decoration: const InputDecoration(labelText: "Título"),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: plat,
                dropdownColor: const Color(0xFF1A0225),
                items: ['PC', 'PS5', 'Switch', 'Xbox']
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (v) => setState(() => plat = v!),
                decoration: const InputDecoration(labelText: "Plataforma"),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<int>(
                value: nota,
                dropdownColor: const Color(0xFF1A0225),
                items: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
                    .map(
                      (n) =>
                          DropdownMenuItem(value: n, child: Text("Nota: $n")),
                    )
                    .toList(),
                onChanged: (v) => setState(() => nota = v!),
                decoration: const InputDecoration(labelText: "Nota"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCELAR"),
            ),
            ElevatedButton(
              onPressed: () {
                if (t1.text.isNotEmpty) {
                  FirestoreService().addGame(
                    Game(
                      titulo: t1.text,
                      plataforma: plat,
                      estado: "Jugando",
                      puntuacion: nota,
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
