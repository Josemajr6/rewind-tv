import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/firestore_service.dart';
import '../models/game_model.dart';

class GamesScreen extends StatefulWidget {
  const GamesScreen({super.key});

  static const List<String> plataformas = [
    'Todas',
    'PC',
    'PS5',
    'PS4',
    'Xbox',
    'Switch',
    'Otras',
  ];

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  String _filtroPlataforma = 'Todas';

  @override
  Widget build(BuildContext context) {
    final Color colorTema = const Color(0xFF00FF66);

    return Column(
      children: [
        // FILTROS
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: GamesScreen.plataformas.length,
            itemBuilder: (context, index) {
              final filtro = GamesScreen.plataformas[index];
              final isSelected = _filtroPlataforma == filtro;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: ChoiceChip(
                  label: Text(filtro),
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
                  onSelected: (bool selected) =>
                      setState(() => _filtroPlataforma = filtro),
                ),
              );
            },
          ),
        ),

        // LISTA
        Expanded(
          child: StreamBuilder<List<Game>>(
            stream: FirestoreService().getGamesFiltrados(
              plataforma: _filtroPlataforma == 'Todas'
                  ? null
                  : _filtroPlataforma,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return Center(
                  child: CircularProgressIndicator(color: colorTema),
                );
              final juegos = snapshot.data ?? [];

              if (juegos.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FaIcon(
                        FontAwesomeIcons.gamepad,
                        size: 50,
                        color: Colors.white24,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "No hay juegos aquí",
                        style: TextStyle(color: Colors.white54),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: juegos.length,
                itemBuilder: (context, index) {
                  final juego = juegos[index];

                  return Card(
                    color: const Color(0xFF051D0D),
                    margin: const EdgeInsets.only(bottom: 15),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(color: colorTema.withOpacity(0.3)),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(15),
                      onTap: () => _editarJuego(context, juego),
                      onLongPress: () => _borrarJuego(context, juego),
                      title: Text(
                        juego.titulo,
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
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: colorTema.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: colorTema.withOpacity(0.5),
                                  ),
                                ),
                                child: Text(
                                  juego.plataforma.toUpperCase(),
                                  style: TextStyle(
                                    color: colorTema,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Icon(
                                Icons.sports_esports,
                                size: 14,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                juego.estado,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          if (juego.resena.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Text(
                              juego.resena,
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
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
                          const FaIcon(
                            FontAwesomeIcons.star,
                            color: Colors.yellow,
                            size: 18,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${juego.puntuacion}",
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

  void _editarJuego(BuildContext context, Game juego) {
    final tituloCtrl = TextEditingController(text: juego.titulo);
    final resenaCtrl = TextEditingController(text: juego.resena);
    String plataforma = GamesScreen.plataformas.contains(juego.plataforma)
        ? juego.plataforma
        : GamesScreen.plataformas[1];
    int puntuacion = juego.puntuacion;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF001005),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: const BorderSide(color: Color(0xFF00FF66), width: 2),
          ),
          title: const Text(
            "EDITAR JUEGO",
            style: TextStyle(
              color: Color(0xFF00FF66),
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
                DropdownButtonFormField(
                  value: plataforma,
                  dropdownColor: const Color(0xFF052010),
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
                  dropdownColor: const Color(0xFF052010),
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
                backgroundColor: const Color(0xFF00FF66),
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                FirestoreService().updateGame(juego.id, {
                  'titulo': tituloCtrl.text,
                  'plataforma': plataforma,
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

  void _borrarJuego(BuildContext context, Game juego) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text(
          "¿Borrar juego?",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text("NO"),
          ),
          TextButton(
            onPressed: () {
              FirestoreService().deleteGame(juego.id);
              Navigator.pop(c);
            },
            child: const Text("SÍ", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
