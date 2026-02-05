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

  final List<Widget> _paginas = const [
    SeriesScreen(),
    MoviesScreen(),
    GamesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Info usuario
    final user = AuthService().currentUser;
    final String nombre =
        user?.displayName?.split(" ")[0].toUpperCase() ?? "INVITADO";

    // Guardo el color actual para usarlo en la UI
    final Color colorActual = _obtenerColorActual();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      // --- 1. APPBAR LIMPIO ---
      appBar: AppBar(
        leadingWidth: 150, // Espacio suficiente para que no se corte
        leading: Align(
          alignment: Alignment.centerLeft, // Alineado a la izquierda limpio
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(
              "Hola, $nombre", // Sin cápsulas, texto limpio
              style: TextStyle(
                color: colorActual, // El color cambia según la sección
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                // Un pequeño brillo en el texto para que destaque del fondo negro
                shadows: [
                  Shadow(color: colorActual.withOpacity(0.8), blurRadius: 10),
                ],
              ),
            ),
          ),
        ),
        title: Image.asset('assets/logo.png', height: 32),
        centerTitle: true,
        backgroundColor: Colors.transparent, // Se integra con el fondo
        elevation: 0,
      ),

      body: _paginas[_currentIndex],

      // --- 2. BARRA INFERIOR MEJORADA ---
      bottomNavigationBar: Container(
        // Decoración del contenedor de la barra
        decoration: BoxDecoration(
          color: Colors.black, // Fondo negro puro
          // Aquí está el truco: Una línea de borde arriba que cambia de color
          border: Border(
            top: BorderSide(
              color: colorActual, // La línea es del color de la sección
              width: 2.0, // Grosor visible
            ),
          ),
          // Sombra hacia arriba (glow)
          boxShadow: [
            BoxShadow(
              color: colorActual.withOpacity(
                0.4,
              ), // Resplandor del color actual
              blurRadius: 15, // Difuminado
              offset: const Offset(0, -4), // Hacia arriba
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent, // Para ver el container de abajo
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,

          // Estilos de los items
          selectedItemColor: colorActual, // El texto e icono activo brilla
          unselectedItemColor: Colors.grey.shade700, // Los inactivos, apagados

          selectedFontSize: 12,
          unselectedFontSize: 10,

          // El icono seleccionado crece un poco
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

      // Botón flotante (con brillo también)
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

  // --- Lógica de colores ---
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
  // DIÁLOGOS (ESTILO NEÓN - MANTENIDOS)
  // ============================================================

  // --- SERIES ---
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
          backgroundColor: const Color(
            0xFF100010,
          ), // Fondo muy oscuro casi negro
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: colorSerie, width: 2), // Borde Neón
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
                  items: SeriesScreen.generos
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

  // --- PELIS ---
  void _dialogoAnadirPeli(BuildContext context) {
    final controladorTitulo = TextEditingController();
    final controladorDirector = TextEditingController();
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
          content: Column(
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
          content: Column(
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
                decoration: const InputDecoration(labelText: "Plataforma"),
                items: GamesScreen.plataformas
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (v) => setState(() => plataformaSeleccionada = v!),
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<int>(
                value: notaSeleccionada,
                dropdownColor: const Color(0xFF052010),
                style: const TextStyle(
                  color: colorJuego,
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
