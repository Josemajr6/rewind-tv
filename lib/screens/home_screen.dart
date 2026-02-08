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

/// pantalla principal que contiene las 4 secciones de la app
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // controla qué pestaña está activa (0=series, 1=pelis, 2=juegos, 3=perfil)
  int _currentIndex = 0;

  // colores neón para cada sección
  static const Color colorSerie = Color(0xFFFF00FF);
  static const Color colorPeli = Color(0xFF00FFFF);
  static const Color colorJuego = Color(0xFF00FF66);
  static const Color colorPerfil = Color(0xFFFFD700);

  // las 4 pantallas que se muestran según la pestaña activa
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

      // -- barra superior con saludo y logo --
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

      // muestro la pantalla activa
      body: _paginas[_currentIndex],

      // -- barra inferior con las 4 pestañas --
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

      // -- botón flotante para añadir (solo visible en series, pelis y juegos) --
      floatingActionButton: _currentIndex == 3
          ? null
          : FloatingActionButton(
              backgroundColor: colorActual,
              child: const Icon(Icons.add, color: Colors.black),
              onPressed: () => _abrirDialogoAnadir(context),
            ),
    );
  }

  /// devuelve el color de la sección activa
  Color _obtenerColorActual() {
    if (_currentIndex == 0) return colorSerie;
    if (_currentIndex == 1) return colorPeli;
    if (_currentIndex == 2) return colorJuego;
    return colorPerfil;
  }

  /// abre el diálogo correcto según la pestaña activa
  void _abrirDialogoAnadir(BuildContext context) {
    if (_currentIndex == 0)
      _dialogoSerie(context);
    else if (_currentIndex == 1)
      _dialogoPeli(context);
    else if (_currentIndex == 2)
      _dialogoJuego(context);
  }

  // ============================================================
  // DIÁLOGO PARA AÑADIR SERIE
  // ============================================================

  void _dialogoSerie(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final tituloCtrl = TextEditingController();
    final resenaCtrl = TextEditingController();
    String genero = SeriesScreen.generos[1]; // evito 'Todos'
    String plataforma = 'Netflix';
    int nota = 5;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF100010),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: colorSerie, width: 2),
          ),
          title: Text(
            "NUEVA SERIE",
            style: TextStyle(color: colorSerie, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
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

                  // plataforma
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

                  // reseña (opcional pero con mínimo)
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

                  // género
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

                  // puntuación
                  DropdownButtonFormField(
                    value: nota,
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
                    onChanged: (v) => setState(() => nota = v as int),
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
              style: ElevatedButton.styleFrom(backgroundColor: colorSerie),
              onPressed: () {
                // solo guardo si pasa la validación
                if (formKey.currentState!.validate()) {
                  FirestoreService().addSerie(
                    Serie(
                      titulo: tituloCtrl.text.trim(),
                      resena: resenaCtrl.text.trim(),
                      genero: genero,
                      puntuacion: nota,
                      plataforma: plataforma,
                    ),
                  );
                  Navigator.pop(context);

                  // mensaje de confirmación
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Serie añadida'),
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

  // ============================================================
  // DIÁLOGO PARA AÑADIR PELÍCULA
  // ============================================================

  void _dialogoPeli(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final tituloCtrl = TextEditingController();
    final directorCtrl = TextEditingController();
    final resenaCtrl = TextEditingController();
    String genero = MoviesScreen.generos[1];
    String plataforma = 'Cine';
    int nota = 5;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF001010),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: colorPeli, width: 2),
          ),
          title: Text(
            "NUEVA PELÍCULA",
            style: TextStyle(color: colorPeli, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // título
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

                  // director (obligatorio para películas)
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

                  // reseña
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
                    value: nota,
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
                    onChanged: (v) => setState(() => nota = v as int),
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
              style: ElevatedButton.styleFrom(backgroundColor: colorPeli),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  FirestoreService().addMovie(
                    Movie(
                      titulo: tituloCtrl.text.trim(),
                      director: directorCtrl.text.trim(),
                      puntuacion: nota,
                      plataforma: plataforma,
                      genero: genero,
                      resena: resenaCtrl.text.trim(),
                    ),
                  );
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Película añadida'),
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

  // ============================================================
  // DIÁLOGO PARA AÑADIR JUEGO
  // ============================================================

  void _dialogoJuego(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final tituloCtrl = TextEditingController();
    final resenaCtrl = TextEditingController();
    String plataforma = 'PC';
    int nota = 5;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF001005),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: colorJuego, width: 2),
          ),
          title: Text(
            "NUEVO JUEGO",
            style: TextStyle(color: colorJuego, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // título
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

                  // plataforma
                  DropdownButtonFormField(
                    value: plataforma,
                    dropdownColor: const Color(0xFF052010),
                    decoration: const InputDecoration(labelText: "Plataforma"),
                    items: GamesScreen.plataformas
                        .where((p) => p != 'Todas')
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

                  // reseña
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
                    value: nota,
                    dropdownColor: const Color(0xFF052010),
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
                    onChanged: (v) => setState(() => nota = v as int),
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
              style: ElevatedButton.styleFrom(backgroundColor: colorJuego),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  FirestoreService().addGame(
                    Game(
                      titulo: tituloCtrl.text.trim(),
                      plataforma: plataforma,
                      puntuacion: nota,
                      resena: resenaCtrl.text.trim(),
                    ),
                  );
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Juego añadido'),
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
}
