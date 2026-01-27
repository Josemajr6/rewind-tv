import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rewind_tv/screens/series_screen.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/serie_model.dart';
import '../models/movie_model.dart';
import '../models/game_model.dart';
import 'movies_screen.dart';
import 'games_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  static const Color cian = Color(0xFF00FFFF);
  static const Color magenta = Color(0xFFFF00FF);
  static const Color verde = Color(0xFF00FF66);

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
        leadingWidth: 120,
        leading: Center(
          child: Text(
            "HOLA, $nombre",
            style: TextStyle(
              color: _colorActual(),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Image.asset('assets/logo.png', height: 30),
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
      body: _paginas[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        currentIndex: _currentIndex,
        selectedItemColor: _colorActual(),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: _colorActual(),
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () => _abrirDialogoSegunTab(),
      ),
    );
  }

  Color _colorActual() {
    if (_currentIndex == 0) return magenta;
    if (_currentIndex == 1) return cian;
    return verde;
  }

  void _abrirDialogoSegunTab() {
    if (_currentIndex == 0) {
      _dialogoNuevaSerie();
    } else if (_currentIndex == 1)
      _dialogoNuevaPeli();
    else
      _dialogoNuevoJuego();
  }

  // --- DIÁLOGOS DE AÑADIR (CREATE) ---

  void _dialogoNuevaSerie() {
    final t1 = TextEditingController();
    final t2 = TextEditingController();
    int nota = 5;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("NUEVA SERIE"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: t1,
                decoration: const InputDecoration(labelText: "Título"),
              ),
              TextField(
                controller: t2,
                decoration: const InputDecoration(labelText: "Reseña"),
              ),
              DropdownButton<int>(
                value: nota,
                items: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
                    .map(
                      (n) =>
                          DropdownMenuItem(value: n, child: Text("Nota: $n")),
                    )
                    .toList(),
                onChanged: (v) => setState(() => nota = v!),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                FirestoreService().addSerie(
                  Serie(
                    titulo: t1.text,
                    resena: t2.text,
                    genero: "Varios",
                    puntuacion: nota,
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

  void _dialogoNuevaPeli() {
    final t1 = TextEditingController();
    final t2 = TextEditingController();
    int nota = 5;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("NUEVA PELÍCULA"),
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
              DropdownButton<int>(
                value: nota,
                items: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
                    .map(
                      (n) =>
                          DropdownMenuItem(value: n, child: Text("Nota: $n")),
                    )
                    .toList(),
                onChanged: (v) => setState(() => nota = v!),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                FirestoreService().addMovie(
                  Movie(titulo: t1.text, director: t2.text, puntuacion: nota),
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: cian),
              child: const Text("GUARDAR"),
            ),
          ],
        ),
      ),
    );
  }

  void _dialogoNuevoJuego() {
    final t1 = TextEditingController();
    String plat = 'PC';
    int nota = 5;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("NUEVO JUEGO"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: t1,
                decoration: const InputDecoration(labelText: "Título"),
              ),
              DropdownButton<String>(
                value: plat,
                items: ['PC', 'PS5', 'Switch', 'Xbox']
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (v) => setState(() => plat = v!),
              ),
              DropdownButton<int>(
                value: nota,
                items: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
                    .map(
                      (n) =>
                          DropdownMenuItem(value: n, child: Text("Nota: $n")),
                    )
                    .toList(),
                onChanged: (v) => setState(() => nota = v!),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                FirestoreService().addGame(
                  Game(
                    titulo: t1.text,
                    plataforma: plat,
                    estado: "Jugando",
                    puntuacion: nota,
                  ),
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: verde),
              child: const Text("GUARDAR"),
            ),
          ],
        ),
      ),
    );
  }
}
