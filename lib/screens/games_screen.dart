import 'package:flutter/material.dart';
import '../models/game_model.dart';
import '../services/firestore_service.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color verde = Color(0xFF00FF66);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0213),
      body: StreamBuilder<List<Game>>(
        stream: FirestoreService().getGames(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: verde));
          }
          final games = snapshot.data!;
          return ListView.builder(
            itemCount: games.length,
            padding: const EdgeInsets.all(15),
            itemBuilder: (context, i) {
              final game = games[i];
              return Card(
                color: Colors.white10,
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: const Icon(Icons.gamepad, color: verde),
                  title: Text(
                    game.titulo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text("${game.plataforma} • ${game.puntuacion}/10"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // BOTÓN EDITAR
                      IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.white70,
                          size: 20,
                        ),
                        onPressed: () => _dialogoEditarJuego(context, game),
                      ),
                      // BOTÓN BORRAR
                      IconButton(
                        icon: const Icon(
                          Icons.delete_forever,
                          color: Colors.redAccent,
                          size: 20,
                        ),
                        onPressed: () =>
                            FirestoreService().deleteGame(game.id!),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _dialogoEditarJuego(BuildContext context, Game game) {
    final t1 = TextEditingController(text: game.titulo);
    String plat = game.plataforma;
    int nota = game.puntuacion;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("EDITAR JUEGO"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: t1,
                decoration: const InputDecoration(labelText: "Título"),
              ),
              DropdownButton<String>(
                value: plat,
                isExpanded: true,
                items: ['PC', 'PS5', 'Switch', 'Xbox']
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (v) => setState(() => plat = v!),
              ),
              DropdownButton<int>(
                value: nota,
                isExpanded: true,
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
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCELAR"),
            ),
            ElevatedButton(
              onPressed: () {
                FirestoreService().updateGame(game.id!, {
                  'titulo': t1.text,
                  'plataforma': plat,
                  'puntuacion': nota,
                });
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
