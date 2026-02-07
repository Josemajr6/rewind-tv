import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/firestore_service.dart';
import '../models/game_model.dart';

/// pantalla de juegos donde gestiono mi biblioteca de videojuegos
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
  bool _ordenDescendente = true;

  @override
  Widget build(BuildContext context) {
    final Color colorTema = const Color(0xFF00FF66); // verde neón

    return Column(
      children: [
        // -- chips de filtro por plataforma --
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
                  onSelected: (_) => setState(() => _filtroPlataforma = filtro),
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

        // -- lista de juegos --
        Expanded(
          child: StreamBuilder<List<Game>>(
            stream: FirestoreService().getGamesFiltrados(
              plataforma: _filtroPlataforma == 'Todas'
                  ? null
                  : _filtroPlataforma,
              descendente: _ordenDescendente,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(color: colorTema),
                );
              }

              final juegos = snapshot.data ?? [];

              if (juegos.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.videogame_asset_off,
                        size: 50,
                        color: Colors.white24,
                      ),
                      SizedBox(height: 20),
                      Text(
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
                      onTap: () => _mostrarDialogoEditar(context, juego),
                      onLongPress: () => _confirmarBorrar(context, juego),
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
                          // plataforma y estado del juego
                          Text(
                            "${juego.plataforma} • ${juego.estado}",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          // reseña si la tiene
                          if (juego.resena.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              juego.resena,
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

  /// diálogo para editar juego con validación
  void _mostrarDialogoEditar(BuildContext context, Game juego) {
    final formKey = GlobalKey<FormState>();
    final tituloCtrl = TextEditingController(text: juego.titulo);
    final resenaCtrl = TextEditingController(text: juego.resena);
    String plataforma = juego.plataforma;
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
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // título del juego
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

                  // plataforma del juego
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

                  // reseña opcional
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

                  // puntuación del 1 al 10
                  DropdownButtonFormField(
                    value: puntuacion,
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
                backgroundColor: const Color(0xFF00FF66),
              ),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  FirestoreService().updateGame(juego.id, {
                    'titulo': tituloCtrl.text.trim(),
                    'plataforma': plataforma,
                    'resena': resenaCtrl.text.trim(),
                    'puntuacion': puntuacion,
                  });
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Juego actualizado'),
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

  void _confirmarBorrar(BuildContext context, Game juego) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text(
          "¿Borrar juego?",
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '¿Eliminar "${juego.titulo}"?',
          style: const TextStyle(color: Colors.white70),
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

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Juego eliminado'),
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
